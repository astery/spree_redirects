class AddHttpCodeToRedirects < ActiveRecord::Migration

  def change
    add_column :spree_redirects, :http_code, :string
  end
end
