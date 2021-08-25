require 'rails_helper'

RSpec.describe "Redirects", type: :request do
  describe "GET /anything" do
    context 'url that matches slug' do
      before do
        @url = Url.create(slug: 'slug1', original_url: 'http://www.goldbelly.com')
      end

      after do
        @url.destroy 
      end

      context 'slug is in cache' do
        before do
          Rails.cache.write('slug1', 'http://www.goldbelly.com')
        end

        after do 
          Rails.cache.clear
        end

        it 'redirects to original url' do
          get '/slug1'
          expect(response).to be_redirect
          expect(response.headers['Location']).to eq('http://www.goldbelly.com')
        end
      end

      context 'slug is not in cache' do
        it 'redirects to original url if slug is not in cache' do
          get '/slug1'
          expect(response).to be_redirect
          expect(response.headers['Location']).to eq('http://www.goldbelly.com')
        end
      end
    end

    context 'url that does not match slug' do
      it 'returns a 404' do
        get '/not_a_slug'
        expect(response).to be_not_found
      end
    end
  end
end
