require 'spec_helper'
require 'ostruct'

module SpreeRedirects
  describe RedirectMiddleware do
    let(:app) { OpenStruct.new }
    let(:redirects_cache) { OpenStruct.new }
    let(:env) { {} }

    subject { described_class.new app }

    before :each do
      allow(SpreeRedirects).to receive(:exclude_paths).and_return([])
      allow(Rails).to receive(:cache).and_return(redirects_cache)
    end

    describe '#call' do
      context 'when the request url is a redirect' do
        it 'responds with a 301' do
          old_url = "http://recharge.com/en-US/carrier-netherlands"
          new_url = "http://recharge.com/en/netherlands/carrier-top-up"

          allow(::Rack::Request).to receive(:new).and_return(OpenStruct.new)
          allow(URI).to receive(:join).and_return(old_url)

          redirects = { old_url  => [301, new_url] }
          allow(redirects_cache).to receive(:fetch).and_return(redirects)
          expect(subject.call(env)).to eq [301, { "Content-Type" => "text/html", "Location" => new_url }, ["Redirecting..."]]
        end

        context 'and the redirect is a path' do
          it 'responds with a 301' do
            old_path = "/en-US/carrier-netherlands"
            new_path = "/en/netherlands/carrier-top-up"

            request = OpenStruct.new(fullpath: '/en-US/carrier-netherlands', query_string: nil)
            allow(::Rack::Request).to receive(:new).and_return(request)

            allow(URI).to receive(:join).and_return("http://recharge.com#{old_path}")

            redirects = { old_path  => [301, new_path] }
            allow(redirects_cache).to receive(:fetch).and_return(redirects)
            expect(subject.call(env)).to eq [301, { "Content-Type" => "text/html", "Location" => new_path }, ["Redirecting..."]]
          end
        end

        context 'and the url contains parameters' do
          it 'responds with a 301' do
            old_url = "http://recharge.com/en-US/carrier-netherlands"
            new_url = "http://recharge.com/en/netherlands/carrier-top-up"
            query_string = "test=true"

            request = OpenStruct.new(query_string: query_string)
            allow(::Rack::Request).to receive(:new).and_return(request)

            allow(URI).to receive(:join).and_return(old_url)

            redirects = { old_url  => [301, new_url] }
            allow(redirects_cache).to receive(:fetch).and_return(redirects)
            expect(subject.call(env)).to eq [301, { "Content-Type" => "text/html", "Location" => "#{new_url}?#{query_string}" }, ["Redirecting..."]]
          end
        end

        context 'and the redirect contains wildcards' do
          it 'responds with a 301' do
            old_url = "http://recharge.com/en-US/carrier-netherlands"
            new_url = "http://recharge.com/en/netherlands/carrier-top-up"

            allow(::Rack::Request).to receive(:new).and_return(OpenStruct.new)
            allow(URI).to receive(:join).and_return(old_url)

            redirect_url = old_url.gsub('US', '??')
            redirects = { redirect_url  => [301, new_url] }
            allow(redirects_cache).to receive(:fetch).and_return(redirects)
            expect(subject.call(env)).to eq [301, { "Content-Type" => "text/html", "Location" => new_url }, ["Redirecting..."]]
          end
        end
      end

      context "when the url is not a redirect" do
        it "continues processing the request" do
          url = "http://recharge.com/en/netherlands/carrier-top-up"
          request = OpenStruct.new(fullpath: '/en/netherlands/carrier-top-up')

          allow(::Rack::Request).to receive(:new).and_return(request)
          allow(URI).to receive(:join).and_return(url)
          allow(redirects_cache).to receive(:fetch).and_return({})

          expect(app).to receive(:call).with(env)

          subject.call(env)
        end
      end
    end
  end
end
