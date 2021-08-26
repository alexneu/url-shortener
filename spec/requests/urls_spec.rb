require 'rails_helper'

RSpec.describe 'Urls', type: :request do
  before do
    setup_users
  end

  after do 
    User.destroy_all
  end

  describe 'GET /urls' do
    before do
      post '/urls', params: { url: { slug: 'slug1', original_url: 'https://www.goldbelly.com' } },
                    headers: { 'Authorization' => "Bearer #{@token1}" }
      post '/urls', params: { url: { slug: 'slug2', original_url: 'https://www.google.com/' } },
                    headers: { 'Authorization' => "Bearer #{@token1}" }
      post '/urls', params: { url: { slug: 'slug3', original_url: 'https://slatestarcodex.com/' } }
      post '/urls', params: { url: { original_url: 'https://www.vox.com' } }
      post '/urls', params: { url: { original_url: 'https://www.nytimes.com' } },
                    headers: { 'Authorization' => "Bearer #{@token1}" }
      post '/urls', params: { url: { original_url: 'https://news.ycombinator.com' } },
                    headers: { 'Authorization' => "Bearer #{@token2}" }
    end

    after do
      Url.destroy_all
    end

    context 'authenticated user 1' do
      it 'should list user urls with user-specified slugs' do
        get '/urls', headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).length).to eq(3)
        expect(JSON.parse(response.body).collect { |url| url['slug'] }).to include('slug1', 'slug2')
      end
    end

    context 'authenticated user 2' do
      it 'should list user urls with 6 character slugs and correct original urls' do
        get '/urls', headers: { 'Authorization' => "Bearer #{@token2}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).length).to eq(1)
        expect(JSON.parse(response.body).collect { |url| url['original_url'] }).to include('https://news.ycombinator.com')
        expect(JSON.parse(response.body)[0]['slug'].length).to eq(6)
      end
    end

    context 'unauthenticated user' do
      it 'should return unauthorized error' do
        get '/urls'
        expect(response).to be_unauthorized
      end
    end
  end

  describe 'GET /urls/:id' do
    before do
      setup_urls
    end

    after do
      Url.destroy_all
    end

    context 'authenticated user 1' do
      it 'should list user owned url' do
        get "/urls/#{@url1_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['slug']).to eq('slug1')
      end
    end

    context 'url made by another user' do
      it 'should not return url' do
        get "/urls/#{@url2_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'request from unauthenticated user' do
      it 'should return unauthorized status' do
        get "/urls/#{@url1_id}"
        expect(response).to be_unauthorized
      end
    end

    context 'url made by unauthenticated user' do
      it 'should not return url' do
        get "/urls/#{@url3_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'invalid url id' do
      it 'should return 404' do
        get '/urls/junkid', headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end
  end

  describe 'DELETE /urls/:id' do
    before do
      setup_urls
    end

    after do
      Url.destroy_all
    end

    context 'authenticated user 1' do
      it 'should list user owned url' do
        delete "/urls/#{@url1_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_no_content
      end
    end

    context 'url made by another user' do
      it 'should not return url' do
        delete "/urls/#{@url2_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'request from unauthenticated user' do
      it 'should return unauthorized status' do
        delete "/urls/#{@url1_id}"
        expect(response).to be_unauthorized
      end
    end

    context 'url made by unauthenticated user' do
      it 'should not return url' do
        delete "/urls/#{@url3_id}", headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'invalid url id' do
      it 'should return 404' do
        delete '/urls/junkid', headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end
  end

  describe 'PUTS /urls/:id' do
    before do
      setup_urls
    end

    after do
      Url.destroy_all
    end

    context 'authenticated user 1' do
      it 'updates slug' do
        put "/urls/#{@url1_id}", params: { url: { slug: 'new_slug' } },  headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['slug']).to eq('new_slug')
      end

      it 'updates original_url' do
        put "/urls/#{@url1_id}", params: { url: { original_url: 'https://stackoverflow.com' } },  headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['original_url']).to eq('https://stackoverflow.com')
      end

      it 'does not update if new url is invalid' do
        put "/urls/#{@url1_id}", params: { url: { original_url: 'http:/stackoverflow.com' } },  headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'url made by another user' do
      it 'should not return url' do
        put "/urls/#{@url2_id}", params: { url: { slug: 'new_slug' } }, headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'request from unauthenticated user' do
      it 'should return unauthorized status' do
        put "/urls/#{@url1_id}", params: { url: { slug: 'new_slug' } }
        expect(response).to be_unauthorized
      end
    end

    context 'url made by unauthenticated user' do
      it 'should not return url' do
        put "/urls/#{@url3_id}", params: { url: { slug: 'new_slug' } }, headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end

    context 'invalid url id' do
      it 'should return 404' do
        put '/urls/junkid', params: { url: { slug: 'new_slug' } }, headers: { 'Authorization' => "Bearer #{@token1}" }
        expect(response).to be_not_found
      end
    end
  end

  def setup_users
    post '/users', params: { user: { username: 'alex', password: 'authpassword' } }
    @token1 = JSON.parse(response.body)['jwt']
    post '/users', params: { user: { username: 'bob', password: 'coolpassword' } }
    @token2 = JSON.parse(response.body)['jwt']
  end

  def setup_urls 
    post '/urls', params: { url: { slug: 'slug1', original_url: 'https://www.goldbelly.com' } }, headers: { 'Authorization' => "Bearer #{@token1}" }
    @url1_id = JSON.parse(response.body).dig('_id', '$oid')
    post '/urls', params: { url: { slug: 'slug2', original_url: 'https://www.nytimes.com' } }, headers: { 'Authorization' => "Bearer #{@token2}" }
    @url2_id = JSON.parse(response.body).dig('_id', '$oid')
    post '/urls', params: { url: { slug: 'slug3', original_url: 'https://www.cnn.com' } }
    @url3_id = JSON.parse(response.body).dig('_id', '$oid')
  end
end
