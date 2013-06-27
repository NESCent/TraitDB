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

end
