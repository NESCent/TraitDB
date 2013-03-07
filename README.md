## Synopsis

TraitDB is a Ruby on Rails web application for storing and searching trait data.  It is in development at [NESCent](http://nescent.org) to support working groups.

## Installation

TraitDB is a Rails 3.2 application.  It requires [ruby](http://ruby-lang.org) and [rubygems](http://rubygems.org) to run.  Other dependencies are specified in the Gemfile.  To get up and running with the development environment, you will need MySQL installed.  TraitDB supports any database compatible with Rails 3.2, but MySQL is configured by default

1. Clone the repository

    git clone git@github.com:NESCent/TraitDB.git
    
2. Install dependencies with `bundle install`
3. Create a `config/database.yml` configuration file.  The `config/database.template` is provided as a template.  In this file, you should specify the database names you wish to use, as well as accounts, passwords, and any database host information.
4. Run `rake db:setup`.  This Instructs Rails to connect to your database and create the required users and databases.  You will be prompted for your database root password.
5. If `rake db:setup` is successful, it will also run a `rake db:migrate` to create database tables.  If not successful, you can create the databases and users manually, then run `rake db:migrate` manually.
6. Create a user in the application.  Run `rails console` to start the interactive shell

    ```ruby
    u = User.new(:username => 'jpublic', :first_name => 'John', :last_name => 'Public', :email => 'jpublic@domain.com', :email_confirmation => 'jpublic@domain.com', :password => 'PasswordHere')
    u.save
    ```

7. If the save result is false, type `u.errors` to see why it failed
8. Start the server with `rails server`.
9. Visit [http://localhost:3000](http://localhost:3000) to access the application.  You should be redirected to the sign in screen.
10. Start a [delayed_job](https://github.com/collectiveidea/delayed_job) worker.  Delayed job is used to execute dataset imports as a background process.  It includes a rake task to start a worker.  In development, just run `rake jobs:work` in an additional terminal process.

## Usage

TraitDB provides an interface to upload and import CSV datasets.  The import is not complete, but files can be uploaded and Import Jobs can be created to process them.

## License

TraitDB is open source under the [MIT License](http://opensource.org/licenses/MIT).  See [LICENSE.txt](LICENSE.txt) for more information.