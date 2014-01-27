## Synopsis

TraitDB is a Ruby on Rails web application for storing and searching trait data.  It is in development at [NESCent](http://nescent.org) to support working groups.

## Installation

TraitDB is a Rails 4 application.  It requires [ruby](http://ruby-lang.org) and [rubygems](http://rubygems.org) to run.  Other dependencies are specified in the Gemfile.  To get up and running with the development environment, you will need Postgres installed.  TraitDB can also be configured to work with MySQL if you wish, but Postgres is preferred.

1. Clone the repository

    ```
    git clone git@github.com:NESCent/TraitDB.git
    ```
    
2. Install dependencies with `bundle install`
3. Set your database credentials as environment variables.  `config/database.yml` will read these values out of the environment.  If your database server is on a different host, set the host/port as well:
<pre><code>export TRAITDB_PG_DEV_USER="traitdb_dev_user"
export TRAITDB_PG_DEV_PASS="your-password-here"</code></pre>
4. Run `rake db:setup`.  This Instructs Rails to connect to your database and create the required users and databases.  If your database requires you to authenticate before creating users/databases, you will be prompted for credentials.
5. If `rake db:setup` is successful, it will also run a `rake db:migrate` to create database tables.  If not successful, you can create the databases and users manually, then run `rake db:migrate` manually.
6. Start the server with `rails server`.
7. Visit [http://localhost:3000](http://localhost:3000) to access the application.  You will be shown the about page.  If you click _Upload_, you will be redirected to the sign-in screen.  From here, you can create an account or sign in with OpenID.
8. Start a [delayed_job](https://github.com/collectiveidea/delayed_job) worker.  Delayed job is used to execute dataset imports as a background process.  It includes a rake task to start a worker.  You can run `rake jobs:work` in an additional terminal process, or run a worker as a daemon with `script/delayed_job start`.

## Usage

### Getting Started - Projects and Users

Data in TraitDB is publicly searchable and organized into projects.  Initially there are no projects, and only administrators can create projects.  Authentication is handled by OpenID, so in order to get started, you must:

1. Sign in with an OpenID by clicking __Sign In__ in the top menu bar.  After signing in, there will be an entry in the users table with your email address.
2. Upgrade this user to an Administrator with the following rake command:

    $ rake traitdb:upgrade_admin[email@domain.com]
    Upgrading email@domain.com

3. Reload your web browser, you will have an __Admin__ menu option.
4. Click __Admin->Projects__, and the __New Project__ button.
5. Fill out the project details and save the new project

Any authenticated user can upload data to any project, but only administrators can create projects and upload Import Configs.

### Upload

TraitDB accepts data uploads in CSV format, with a specific focus on data validation and organization.  In order to upload data into a project, you must write at least one import configuration file in YAML format. This configuration file will contain the project-specific data for your spreadsheets, as well as allowable values and rules for data relationships and which columns to import, ignore, or convert.

For detailed information on writing import configs, see the documentation on the [wiki](../../wiki).

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
