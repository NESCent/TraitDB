namespace :traitdb do
  desc "Clear all imported data and taxa"
  task :clear => :environment do
    Taxon.destroy_all
    Otu.destroy_all
    CsvDataset.destroy_all
    CategoricalTrait.destroy_all
    ContinuousTrait.destroy_all
    TraitGroup.destroy_all
    OtuMetadataField.destroy_all
  end
  desc "Clear data for a project"
  task :clear_project, [:project_id] => :environment do |t, args|
    if args.project_id.nil?
      puts "Error: Please supply a project id:\n\n"
      puts "rake #{t}[61]\n\n"
    else
      project = Project.find(args.project_id)
      puts "Clearing data for project id #{args.project_id} (#{project.name}) in 3 seconds..."
      sleep 3
      puts "Clearing data. This may take a while."
      project.clear_all_data!
    end
  end
  desc "Delete all projects (CLEARS ALL DATA)"
  task :delete_projects => :environment do
    Project.destroy_all
  end
  desc "Upgrade a user account to administrator"
  task :upgrade_admin, [:email] => :environment do |t, args|
    if args.email.nil?
      puts "Error: Please supply an email address of an existing account:\n\n"
      puts "rake #{t}[email@domain.com]\n\n"
    else 
      u = User.where(:email => args.email).first
      if u.nil?
        puts "Error: Unable to locate user with email #{args.email}" 
      else
        puts "Upgrading #{args.email}"
        u.admin = true
        u.save
      end
    end
  end
  desc "Downgrade a user account from administrator"
  task :downgrade_admin, [:email] => :environment do |t, args|
    if args.email.nil?
      puts "Error: Please supply an email address of an existing account:\n\n"
      puts "rake #{t}[email@domain.com]\n\n"
    else 
      u = User.where(:email => args.email).first
      if u.nil?
        puts "Error: Unable to locate user with email #{args.email}" 
      else
        puts "Downgrading #{args.email}"
        u.admin = false
        u.save
      end
    end
  end

end
