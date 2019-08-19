class AddSpreeNamespaceToRedirects < ActiveRecord::Migration[5.2]
  
  def self.up
    rename_table :redirects, :spree_redirects
  end

  def self.down
    rename_table :spree_redirects, :redirects
  end

end
