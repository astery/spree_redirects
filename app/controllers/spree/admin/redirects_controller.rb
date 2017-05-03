require 'csv'

class Spree::Admin::RedirectsController < Spree::Admin::ResourceController
  cache_sweeper Spree::RedirectsSweeper, :only => [:create, :update, :destroy]

  def new
    @redirect = ::Spree::Redirect.new
    render :layout => !request.xhr?
  end

  def create
    by_csv if params_by_csv.present?
    super unless params_by_csv.present?
  end

  private

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "old_url asc"
    @search = ::Spree::Redirect.search(params[:q])
    @collection = @search.result.page(params[:page]).per(Spree::Config[:orders_per_page])
  end

  def by_csv
    existing_urls = []
    CSV.read(params_by_csv.path, headers:true).each do |row|
      old_redirect_found = ::Spree::Redirect.where(old_url: row['old_url']).first
      existing_urls << old_redirect_found.old_url if old_redirect_found
      next if old_redirect_found
      redirect = ::Spree::Redirect.new row.to_hash
      result = redirect.save
      existing_urls << redirect.old_url unless result
    end

    flash[:success] = 'Redirects successfully imported.'
    flash[:error] = 'Redirects are not imported, because already exist: ' + existing_urls.join(', ')

    redirect_to :back
  end

  def params_by_csv
    params.require(:csv_file)
  end
end
