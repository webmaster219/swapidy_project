class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_uri #deployed on swapidy.com
  before_filter :prepaire_add_honey
  
  def check_uri
    #session[:cart_products] = {:sell => [], :buy => []}
    
    return unless Rails.env == 'production'
    if !/^www/.match(request.host)
      redirect_to request.protocol + "www." + request.host_with_port + request.fullpath 
      #redirect_to "https://www." + request.host_with_port + request.fullpath 
    #elsif !request.ssl?
    #  redirect_to :protocol => "https://"
    end
  end
  
  def page_title(title)
    @page_title = title
  end
  
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_not_found
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end
  
  def require_login
    unless user_signed_in?
      redirect_to "/", :flash => { :info => "You must first log in or sign up before accessing this page." }
    end  
  end
  
  def prepaire_add_honey
    #init new payment to add honey
    return unless user_signed_in?
    @payment = PaymentTransaction.new()
    @payment.user = current_user
    @payment.card_type = current_user.card_type
    @payment.card_expired_year = current_user.card_expired_year
    @payment.card_expired_month = current_user.card_expired_month
    @payment.card_name = current_user.card_name
    
    @free_honey = FreeHoney.new if current_user.free_honey_sendable?
  end
  
  def check_to_display_guide
    session[:need_to_display_guide] = true if current_user && current_user.sign_in_count <= 3
  end

  def cart_products
    session[:cart_products] = {:sell => [], :buy => []} if session[:cart_products].nil?
    
    {:sell => session[:cart_products][:sell].map {|obj_hash| OrderProduct.new(obj_hash)},
     :buy => session[:cart_products][:buy].map {|obj_hash| OrderProduct.new(obj_hash)}
    }
  end

  def add_cart_product cart_params
    session[:cart_products] = {:sell => [], :buy => []} if session[:cart_products].nil?
    
    if cart_params[:type] && cart_params[:type].to_s == "sell"
      session[:cart_products][:sell] << {:product_id => cart_params[:product_id], :price => cart_params[:price], :using_condition => cart_params[:using_condition]}
    elsif cart_params[:type] && cart_params[:type].to_s == "buy"
      session[:cart_products][:buy] << {:product_id => cart_params[:product_id], :price => cart_params[:price], :using_condition => cart_params[:using_condition]}
    end
     Rails.logger.info "session cart #{session[:cart_products].to_s}"
  end
  
  def clear_cart_products
    session[:cart_products] = nil
  end

  private
    
    def render_not_found
      render '/error_pages/404'
    end

end
