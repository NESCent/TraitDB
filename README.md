## Synopsis

TraitDB is a Ruby on Rails web application for storing and searching trait data.  It is in development at [NESCent](http://nescent.org) to support working groups.

## Installation

TraitDB is a Rails 4 application.  It requires [ruby](http://ruby-lang.org) and [rubygems](http://rubygems.org) to run.  Other dependencies are specified in the Gemfile.  To get up and running with the development environment, you will need Postgres installed.  TraitDB can also be configured to work with MySQL if you wish, but Postgres is preferred.

1. Clone the repository

    ```
    git clone git@github.com:NESCent/TraitDB.git
    ```
    
2. Install dependencies with `bundle install`
3. Create a `config/database.yml` configuration file.  The `config/database.template` is provided as a template.  In this file, you should specify the database names you wish to use, as well as accounts, passwords, and any database host information.
4. Run `rake db:setup`.  This Instructs Rails to connect to your database and create the required users and databases.  You will be prompted for your database root password.
5. If `rake db:setup` is successful, it will also run a `rake db:migrate` to create database tables.  If not successful, you can create the databases and users manually, then run `rake db:migrate` manually.
6. Start the server with `rails server`.
7. Visit [http://localhost:3000](http://localhost:3000) to access the application.  You will be shown the about page.  If you click _Upload_, you will be redirected to the sign-in screen.  From here, you can create an account or sign in with OpenID.
8. Start a [delayed_job](https://github.com/collectiveidea/delayed_job) worker.  Delayed job is used to execute dataset imports as a background process.  It includes a rake task to start a worker.  In development, just run `rake jobs:work` in an additional terminal process.

## Usage

### Access

Data in TraitDB is publicly searchable.  Authenticating with OpenID is a prerequisite for uploading data.  User accounts are created in the database on first login with OpenID.

Administrator users can create projects and manage upload configurations.  By default, new user accounts are not administrators.  After installing TraitDB initially, you'll need to upgrade your user account to an admin in order to create a project.:

    rake traitdb:upgrade_admin[email@domain.com]

The upgrade_admin task only works for existing user accounts, so you will need to authenticate with OpenID first to create that account.

### Upload

TraitDB accepts data uploads in CSV format, with a specific focus on data validation and organization.  In order to upload data into a project, you must write at least one import configuration file in YAML format. This configuration file will contain the project-specific data for your spreadsheets, as well as allowable values and rules for data relationships and which columns to import, ignore, or convert.

Examples for the configuration files are in the [lib/traitdb_import](lib/traitdb_import) directory.

Generally, the CSV files are required to have the following general characteristics

1. The first row contains column header names
    The column names include Taxonomic ranks (e.g. Order, Genus, Species), names of traits, and column names for metadata.
2. Each data row includes trait data and metadata for **one** Operational Taxonomic Unit (OTU)
3. Data for a single trait (column) may be either categorical (One or more string tokens separated by a delimeter) or continuous (floating point values)
4. Source / Reference information for a trait may be in an associated column

As an admin user, you can upload and manage Import Configs for a project.  Authenticated users will be able to choose an Import Config when they upload data to the project.

At the upload stage, the user can get information about the Import Config, or download a template CSV file that conforms to it.

## License

TraitDB is open source under the [MIT License](http://opensource.org/licenses/MIT).  See [LICENSE.txt](LICENSE.txt) for more information.
