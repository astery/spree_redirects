module SpreeRedirects
  class RedirectMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ::Rack::Request.new(env)
      return @app.call(env) if SpreeRedirects.exclude_paths.detect{|p| request.fullpath.match(p)}

      redirects = Rails.cache.fetch("spree_redirects", race_condition_ttl: 10.minutes) do
        Spree::Redirect.all.inject({}) do |result, redirect|
          result[redirect.old_url] = [redirect.http_code, redirect.new_url]
          result
        end
      end

      uri = URI.join("#{request.scheme}://#{request.host_with_port}", request.fullpath)

      if redirect_to = get_redirect_values(redirects, uri.to_s) || get_redirect_values(redirects, request.fullpath)
        status = redirect_to[0].blank? ? 301 : redirect_to[0]
        location = request.query_string.present? ? "#{redirect_to[1]}?#{request.query_string}" : redirect_to[1]

        [ status, { "Content-Type" => "text/html", "Location" => location }, [ "Redirecting..." ] ]
      else
        @app.call(env)
      end
    rescue
      @app.call(env)
    end

    private

    def get_redirect_values(redirects, url)
      url_without_params = url.gsub(/\?.*$/, '')
      url_without_params = url_without_params.chop if url_without_params.last == '/'

      redirects.detect do |redirect_url, _values|
        Regexp.new(redirect_url.gsub('?','.')) =~ url_without_params
      end.try(:[], 1)
    end
  end
end
