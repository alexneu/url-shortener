# README
**Alex Neuhausen's Goldbelly URL Shortener Project**

## Configuration
Rails 6.1.4.1 running on Ruby 2.7.3 with a MongoDB Database implemented with Mongo v2.15 Ruby Driver gem and the Mongoid ODM v7.0.13 gem
We could have used the latest stable Ruby, version 3.0.2, but it doesn't make any difference for this project and I know that some hosting/orchestration services such as AWS Elastic Beanstalk still only run Ruby 2.7.3.

## Setup
### Database
brew tap mongodb/brew
brew install mongodb-community@5.0brew services start mongodb-community@5.0
The mongoid gem will initialize our tables as needed based on our models

### Web Service
Install ruby 2.7.3, I recommend using nvm or rbenv, ruby version managers.
Install rails: gem install rails
Install project gems: bundle install
spring stop
spring start (Needed on every change to db configuration, sometimes Mongo doesn't work until you do this)
Start server: rails s

### Running The Test Suite
bundle exec rspec

## Notes on Implementation

### Database
A few observations about the nature of the data we will store:
1. We potentially need to store billions of records.
2. Each object we store is small (less than 1K).
3. There are no relationships between records—other than storing which user created a URL.
4. Our service is read-heavy.

We need two tables: one for storing information about the URL mappings and one for the user’s data who created the short link, to enable updating/deleting/index view of a user's urls.

At scale, if we anticipate millions or hundreds of millions of urls generated per month, thus billions of rows and pretty minimal relationships between objects (just matching urls to a given user), a NoSQL store like MongoDB makes more sense. I'm using the mongoid gem to implement MongoDB in Rails. We’re going to build a mostly-restful API because it’s a convention that Rails favors, a URL is a nice restful object (In our case, Create, Read, Delete and Index (for a given user to see all of their custom urls) all make sense. 

### Functionality
How would we perform a key lookup? We can look up the key in our database to get the full URL. If it’s present in the DB, issue an “HTTP 302 Redirect” status back to the browser, passing the stored URL in the “Location” field of the request. If that key is not present in our system, issue an “HTTP 404 Not Found” status or redirect the user back to the homepage. We'll use a catch-all route at the end of our routes to handle the general redirect case.

### Slug Generation
Given that this is a takehome problem, for slugs that we generate, I'm going to use an MD5 hash base64 on the original url and take the first 6 characters of the hash as our system-generated slug. MD5 doesn't guarantee unique digests, which means urls can hash to the same key, ie. slug, so that’s obviously bad. We’ll put a hack in to add a random number to the hash input (aka a nonce) based on Time.now. That’s obviously not scalable once we have a full database and start getting non-negligible numbers of conflicts, at which point we could add more characters to our system-generated slugs or implement a production-level solution would use a Slug generation service to provide guaranteed unique slugs.

### Authentication
For users to be able to update and delete this saved urls, we need the ability to create user accounts and authenticate user sessions. I implemented the authentication using the bcrypt gem and rails's has_secure_password method for authentication. Unauth’d users can create shortened urls, but they can’t destroy or edit urls or access the index action to see all of the url’s they have created. This is similar to how bit.ly works, where authenticated/paid accounts can get additional features like metrics.

### Caching
Using a simple cache configuration to store recently used slug-redirect_url pairs and save DB bandwidth.
Currently set for memcache in production, memory_store in dev. 
Memory_store would be faster in production, but figure we're planning on some scale and the ability to run multiple server processes.

### Automated Test Suite
I chose to use Rspec for unit tests because I'm familiar with it. There's test coverage for the CRUD methods for the url model and controller, the create method for the user model and controller, and the auth and redirect controller.
It would also be nice to implement Rswag integration tests, because you get included documentation and an interactive testing interface, but I ran out of time.

## Example Usage
**Test with Chrome Plugin, Advanced REST client. These cover a lot of the test cases in the automated test suite.**

### Unauthenticated users
1. User-defined slug: Post localhost:3000/urls, JSON body: url: { slug: ‘slug1’, original_url: 'http://www.goldbelly.com' } 
2. User-defined slug with expiration: Post localhost:3000/urls, JSON body { slug: ‘slug2’, original_url: 'http://www.goldbelly.com’, expiration: ‘2629782086’ } 
3. Try creating a url with an invalid expiration date in the past, verify you get a meaningful error response. Post localhost:3000/urls, JSON body { slug: ‘slug2’, original_url: 'http://www.goldbelly.com’, expiration: '1' } 
4. Try creating a duplicate slug, verify you get a meaningful error.
5. With unauthenticated user, generate a random slug: Post localhost:3000/urls, JSON body { original_url: 'http://www.goldbelly.com' } 
6. Do it again, get a new, different slug.
7. With unauthenticated user, app-determined slug and invalid url: Post localhost:3000/urls, JSON body { original_url: 'http://www.goldbelly.com' }. Verify you get an error.
8. Verify that some of the slugs you created actually work: Open a browser tab and visit one of your slugs: localhost:3000/:slug and you should get redirected to the original url.
9. Verify that one of the random slugs you created actually works.

### Authenticated Users
1. Create new user with Post to http://localhost:3000/users, body: user: { username: ‘Alex’, password: ‘mypassword’ }
2. Get back a jwt like eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNjEyNWEyMTE5ZDc0ZTJjNDhiNmZiYzEyIn0.vZchbjrOzMNAEo8EFjjSdtfRIk8virJXfhIjddg7yvA. Copy that to your notepad.
3. Also, verify that we set the correct "Last login" time for returned user object.
4. Now we can do authenticated requests by putting in a header in our Posts: { 'Authorization': 'Bearer <token>' }
5. Try posting to http://localhost:3000/urls with our token.
6. Create a new url, verify it works.
7. Fetch all of our authenticated user’s urls with the index endpoint, GET http://localhost:3000/urls
8. Fetch a single authenticated user url with the read endpoint, GET http://localhost:3000/urls/:url_id
9. Delete a url, DELETE http://localhost:3000/urls/:url_id
10. Verify that if we remove a character from our jwt header, we get a “Please log in” message for the Index, Get, and Delete endpoints.
11. Remove the header, verify that redirecting from a slug still works for unauthenticated users.