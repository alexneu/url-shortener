# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* 2.7.3

* MongoDB

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...




Good problem summary here: https://www.educative.io/courses/grokking-the-system-design-interview/m2ygV4E81ARA production-level solution would use a Key generation service to provide unique keys. Given the problem scope, we’re just going to use an MD5 hash on the original url and take the first 6 characters of the hash as our system-generated slug. MD5 is cryptographically broken and unique urls can hash to the same key, so that’s obviously bad. We’ll put a hack in to add a random number to the hash input if there’s a conflict, but that’s obviously not scalable once we have a full database and start getting non-negligible numbers of conflicts.At scale, if we anticipate millions or hundreds of millions of urls generated per month, thus billions of rows and pretty minimal relationships between objects (just matching urls to a given user), a NoSQL store like MongoDB or DynamoDB makes more sense. We’ll use MongoDB to run this locally.We’re going to build a restful API because it’s a convention that Rails favors, a URL is a nice restful object (In our case, Create, Read, Delete and Index (for a given user to see all of their custom urls) all make sense.


Install ruby 2.7.3, I recommend using ram or rbenv, ruby version managers.
gem install rails
rails new url_shortener --skip-active-record --skip-bundle --api


rake db:setup
rails g model User username:string password_digest:string last_login:datetimerails g model Url user_id:string slug:string original_url:string expiration:datetime
rails g controller ShortenedUrls