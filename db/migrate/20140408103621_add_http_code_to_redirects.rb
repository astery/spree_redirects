class AddHttpCodeToRedirects < ActiveRecord::Migration[5.2]

  def change
    add_column :spree_redirects, :http_code, :string
  end
end
