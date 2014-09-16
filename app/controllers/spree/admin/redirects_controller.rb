class Spree::Admin::RedirectsController < Spree::Admin::ResourceController

  def new
    @redirect = Spree::Redirect.new
    render :layout => !request.xhr?
  end

  private

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "old_url asc"
    @search = Spree::Redirect.search(params[:q])
    @collection = @search.result.page(params[:page]).per(Spree::Config[:orders_per_page])
  end

  def redirect_attributes
    params.require(:redirect).permit(:old_url, :new_url, :http_code)
  end

end
