# Spree Redirects

Spree Redirects adds an interface for redirecting old urls to new ones. It's for when you replace an existing site with a shiny new spree site and want to avoid broken links and broken hearts.

To get a better idea of what it does, just follow the Demo instructions below...

Cloned from: git://github.com/citrus/spree_redirects.git
Modified to Be compatible with Spree 2-0-stable and Spree 2-3-stable

Added possibility to exclude paths from Redirection
-- create an initializer with
```ruby
CgLanguage.exclude_paths = ["/admin"]
```

Added possibility to use full url redirection
Added caching to improve speed.

------------------------------------------------------------------------------
Installation
------------------------------------------------------------------------------

Install spree_redirects by adding the following to your existing spree site's Gemfile:

```ruby
gem 'spree_redirects', :git => 'git://github.com/cgservices/spree_redirects.git'
```

Bundle:

```bash
bundle
```

Then run the generator which copies the migration template into your project:

```bash
rails g spree_redirects:install
```

Migrate your database:

```bash
rake db:migrate
```

And boot up your server:

```bash
rails s
```

You should now be up and running at [http://localhost:3000](http://localhost:3000)!


------------------------------------------------------------------------------
Testing
------------------------------------------------------------------------------

Clone this repo to where you develop, bundle up and run dummier to get the show started:

```bash
git clone git://github.com/citrus/spree_redirects.git
cd spree_redirects
bundle install
bundle exec dummier
```

This will generate a fresh rails app in `test/dummy`, install spree_core & spree_redirects, then migrate the test database. Sweet.

Now just run the tests with:

```bash
bundle exec rake
```


------------------------------------------------------------------------------
Demo
------------------------------------------------------------------------------

You can easily use the test/dummy app as a demo of spree_redirects. Just `cd` to where you develop and run:

```bash
git clone git://github.com/citrus/spree_redirects.git
cd spree_redirects
cp test/dummy_hooks/after_migrate.rb.sample test/dummy_hooks/after_migrate.rb
bundle install
bundle exec dummier
cd test/dummy
rails s
```

Now log into the admin, click the 'Configuration' tab, then click 'Manage Redirects'. Try adding a redirect for `/shop.php` that points to `/products`, then visit [http://localhost:3000/shop.php](http://localhost:3000/shop.php). You should be redirected to `/products`.

------------------------------------------------------------------------------
License
------------------------------------------------------------------------------

Copyright (c) 2011 - 2012 Spencer Steffen and Citrus, released under the New BSD License All rights reserved.
