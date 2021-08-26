require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe Url, type: :model do
  before do
    travel_to Time.local(2021)
  end

  after do
    travel_back
    Url.destroy_all
  end
  
  describe '#new' do
    it "is valid with a slug and a valid original_url" do
      url = Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      expect(url).to be_valid
      url.destroy
    end

    it "is not valid without a slug" do
      url = Url.new(slug: nil, original_url: 'https://www.goldbelly.com')
      expect(url).to_not be_valid
    end

    it "is not valid with a duplicate slug" do
      url = Url.create(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      url2 = Url.create(slug: 'slug1', original_url: 'https://www.goldbelly.com')
      expect(url2).to_not be_valid
    end

    it "is not valid with a slug longer than 32 characters" do
      url = Url.new(slug: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz', original_url: 'https://www.goldbelly.com')
      expect(url).to_not be_valid
    end

    it "is not valid without an original_url" do
      url = Url.new(slug: 'slug1', original_url: nil)
      expect(url).to_not be_valid
    end

    it "is not valid with a malformed url" do
      url = Url.new(slug: 'slug1', original_url: 'http:/cnn.com')
      expect(url).to_not be_valid
    end

    it "is not valid with a malformed url" do
      url = Url.new(slug: 'slug1', original_url: 'thisisjustaword')
      expect(url).to_not be_valid
    end

    it "accepts an optional expiration time in the future" do
      url = Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now + 1.day)
      expect(url).to be_valid
    end

    it "does not accept an expiration time in the past" do
      url = Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now - 1.day)
      expect(url).to_not be_valid
    end

    it "sets a default expiration if one is not given" do
      url = Url.new(slug: 'slug1', original_url: nil)
      expect(url.expiration).to eq Time.now + 2.years
    end

    it "accepts an optional user_id" do
      url = Url.new(slug: 'slug1', original_url: 'https://www.goldbelly.com', expiration: Time.now + 1.day, user_id: '123')
      expect(url.user_id).to eq '123'
    end
  end

  describe '#prep_user_slug' do
    it 'removes invalid special characters in user slug' do
      params = { slug: 'abc$#!@?&' }
      Url.prep_user_slug(params)
      expect(params[:slug]).to eq 'abc'
    end
  end

  describe '#prep_random_slug' do
    it 'generates a random 6 character slug' do
      params = { original_url: 'https://www.goldbelly.com' }
      Url.prep_random_slug(params)
      expect(params[:slug]).to eq 'TZ95L5'
    end
  end

  describe '#generate_slug' do
    it 'generates a random 6 character slug for the user' do
      slug = Url.generate_slug('https://www.goldbelly.com')
      expect(slug).to eq 'TZ95L5'
    end
  end

  describe '#generate_slug' do
    it 'generates a unique random 6 character slug for each original url' do
      slug1 = Url.generate_slug('https://www.goldbelly.com')
      slug2 = Url.generate_slug('https://www.google.com')
      expect(slug1).to_not eq slug2
    end
  end

  describe '#generate_slug' do
    it 'generates a unique random 6 character slug for same url if time is different' do
      slug1 = Url.generate_slug('https://www.goldbelly.com')
      travel_to Time.local(2020)
      slug2 = Url.generate_slug('https://www.goldbelly.com')
      expect(slug1).to_not eq slug2
    end
  end
end
