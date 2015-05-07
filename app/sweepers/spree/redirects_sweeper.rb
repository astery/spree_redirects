module Spree
  class RedirectsSweeper < ActionController::Caching::Sweeper
    observe Redirect

    def after_create(redirect)
      expire_fragment("spree_redirects")
    end

    def after_update(redirect)
      expire_fragment("spree_redirects")
    end

    def after_destroy(redirect)
      expire_fragment("spree_redirects")
    end
  end
end