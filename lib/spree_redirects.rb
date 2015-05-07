require "spree_core"

require "spree_redirects/version"
require "spree_redirects/engine"
require "spree_redirects/redirect_middleware"

module SpreeRedirects
  mattr_accessor :exclude_paths

  def exclude_paths
    @@exclude_paths || []
  end
end
