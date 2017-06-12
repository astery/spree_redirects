require 'csv'

class Spree::Admin::RedirectsController < Spree::Admin::ResourceController
  cache_sweeper Spree::RedirectsSweeper, :only => [:create, :update, :destroy]

  def new
    @redirect = Spree::Redirect.new
    render :layout => !request.xhr?
  end

  def create
    by_csv if csv_upload?
    super unless csv_upload?
  end

  private

  def csv_upload?
    paramz = params.permit(:csv)
    return true if paramz[:csv].present?
    false
  end

  def collection
    params[:q] ||= {}
    params[:q][:s] ||= "old_url asc"
    @search = Spree::Redirect.search(params[:q])
    @collection = @search.result.page(params[:page]).per(Spree::Config[:orders_per_page])
  end

  def by_csv
    import_csv

    flash[:success] = 'Redirects are successfully imported.'
    redirect_to :back
  end

  def import_csv
    CSV.read(params_by_csv.path, headers:true).each do |row|
      existing_redirect = Spree::Redirect.find_by_old_url row['old_url']
      if existing_redirect.present?
        existing_redirect.update(new_url: row['new_url'])
      else
        Spree::Redirect.create(row.to_hash)
      end
    end
  end

  def params_by_csv
    params.require(:csv_file)
  end
end
