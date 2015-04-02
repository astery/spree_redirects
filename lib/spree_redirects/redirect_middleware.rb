module SpreeRedirects
  class RedirectMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ::Rack::Request.new(env)
      return @app.call(env) if SpreeRedirects.exclude_paths.detect{|p| request.fullpath.match(p)}

      redirects = Rails.cache.fetch("spree_redirects", race_condition_ttl: 10.minutes) do
        Spree::Redirect.all.inject({}){|result, item| result[item.old_url] = [item.http_code, item.new_url];result}
      end
      uri = URI.join("#{request.scheme}://#{request.host_with_port}", request.fullpath)
      uri.query = request.query_string unless request.query_string.blank?
      if redirect_to = (redirects[uri.to_s] || redirects[request.fullpath])
        status = redirect_to[0].blank? ? 301 : redirect_to[0]
        [ status, {"Content-Type" => "text/html", "Location" => redirect_to[1] }, [ "Redirecting..." ] ]
      else
        @app.call(env)
      end
    rescue
      @app.call(env)
    end
  end
end
