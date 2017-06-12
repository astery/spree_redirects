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
    return unless csv_header_valid?

    CSV.read(params_by_csv.path, headers: true, col_sep: ';').each do |row|
      existing_redirect = Spree::Redirect.find_by_old_url row['Old URL']
      if existing_redirect.present?
        existing_redirect.update(new_url: row['New URL'])
      else
        Spree::Redirect.create(old_url: row['Old URL'], new_url: row['New URL'], http_code: '301')
      end
    end
  end

  def params_by_csv
    params.require(:csv_file)
  end

  def csv_header_valid?
    correct_header = ['Old URL', 'New URL']
    imported_header = CSV.read(params_by_csv.path, col_sep: ';').first

    return true if imported_header == correct_header
    flash[:error] = "CSV header must be: #{correct_header}, you entered: #{imported_header}"
    false
  end
end
