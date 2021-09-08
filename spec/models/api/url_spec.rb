require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe Api::Url, type: :model do
  before do
    travel_to Time.local(2021)
  end

  after do
    travel_back
    Api::Url.destroy_all
  end
  
  describe '#new' do
    it "is valid with a slug and a valid original_Api::Url" do
      url = Api::Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      expect(url).to be_valid
      url.destroy
    end

    it "is not valid without a slug" do
      url = Api::Url.new(slug: nil, original_url: 'https://www.goldbelly.com')
      expect(url).to_not be_valid
    end

    it "is not valid with a duplicate slug" do
      url = Api::Url.create(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      url2 = Api::Url.create(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      expect(url2).to_not be_valid
    end

    it "is not valid with a slug longer than 32 characters" do
      url = Api::Url.new(slug: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz', original_url: 'https://www.goldbelly.com')
      expect(url).to_not be_valid
    end

    it "is not valid without an original_url" do
      url = Api::Url.new(slug: 'slug1', original_url: nil)
      expect(url).to_not be_valid
    end

    it "is not valid with a malformed url" do
      url = Api::Url.new(slug: 'slug1', original_url: 'http:/cnn.com')
      expect(url).to_not be_valid
    end

    it "is not valid with a malformed url" do
      url = Api::Url.new(slug: 'slug1', original_url: 'thisisjustaword')
      expect(url).to_not be_valid
    end

    it "accepts an optional expiration time in the future" do
      url = Api::Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now + 1.day)
      expect(url).to be_valid
    end

    it "does not accept an expiration time in the past" do
      url = Api::Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now - 1.day)
      expect(url).to_not be_valid
    end

    it "sets a default expiration if one is not given" do
      url = Api::Url.new(slug: 'slug1', original_url: nil)
      expect(url.expiration).to eq Time.now + 2.years
    end

    it "accepts an optional user_id" do
      url = Api::Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now + 1.day, user_id: '123')
      expect(url.user_id).to eq '123'
    end
  end

  describe '#prep_user_slug' do
    it 'removes invalid special characters in user slug' do
      params = { slug: 'abc$#!@?&' }
      Api::Url.prep_user_slug(params)
      expect(params[:slug]).to eq 'abc'
    end
  end

  describe '#prep_random_slug' do
    it 'generates a random 6 character slug' do
      params = { original_url: 'https://www.goldbelly.com' }
      Api::Url.prep_random_slug(params)
      expect(params[:slug]).to eq 'TZ95L5'
    end
  end

  describe '#generate_slug' do
    it 'generates a random 6 character slug for the user' do
      slug = Api::Url.generate_slug('https://www.goldbelly.com')
      expect(slug).to eq 'TZ95L5'
    end
  end

  describe '#generate_slug' do
    it 'generates a unique random 6 character slug for each original url' do
      slug1 = Api::Url.generate_slug('https://www.goldbelly.com')
      slug2 = Api::Url.generate_slug('https://www.google.com')
      expect(slug1).to_not eq slug2
    end
  end

  describe '#generate_slug' do
    it 'generates a unique random 6 character slug for same url if time is different' do
      slug1 = Api::Url.generate_slug('https://www.goldbelly.com')
      travel_to Time.local(2020)
      slug2 = Api::Url.generate_slug('https://www.goldbelly.com')
      expect(slug1).to_not eq slug2
    end
  end

  describe '#cost' do
    it 'calculates the correct slug cost for goly' do
      url = Api::Url.new(slug: 'goly', original_url: 'https://www.goldbelly.com')
      expect(url.cost).to eq 5
    end

    it 'calculates the correct slug cost for oely' do
      url = Api::Url.new(slug: 'oely', original_url: 'https://www.goldbelly.com')
      expect(url.cost).to eq 6
    end

    it 'calculates the correct slug cost for gole' do
      url = Api::Url.new(slug: 'gole', original_url: 'https://www.google.com')
      expect(url.cost).to eq 6
    end

    it 'calculates the correct slug cost for goog' do
      url = Api::Url.new(slug: 'goog', original_url: 'https://www.google.com')
      expect(url.cost).to eq 8
    end
  end

  describe '#suggested_slug' do
    it 'suggests the cheapest possible slug for goldbelly' do
      url = Api::Url.new(original_url: 'goldbelly')
      expect(url.suggested_slug).to eq 'gldb'
    end

    it 'suggests the cheapest possible slug for google' do
      url = Api::Url.new(original_url: 'google')
      expect(url.suggested_slug).to eq 'gloe'
    end

    it 'suggests the cheapest possible slug for hi' do
      url = Api::Url.new(original_url: 'hi')
      expect(url.suggested_slug).to eq 'hihh'
    end

    it 'suggests the cheapest possible slug for ae' do
      url = Api::Url.new(original_url: 'ae')
      expect(url.suggested_slug).to eq 'aeaa'
    end
  end
end
