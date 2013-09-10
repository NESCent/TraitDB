class AddManyToManyUniqueIndices < ActiveRecord::Migration
  def change
    add_index :iczn_groups_projects, [:iczn_group_id, :project_id], :unique => true, :name => 'by_iczn_group_and_project'
    add_index :projects_users, [:project_id, :user_id], :unique => true, :name => 'by_project_and_user'
    add_index :otus_taxa, [:otu_id, :taxon_id],:name => 'by_otu_and_taxon'
    add_index :taxa_trait_groups, [:taxon_id, :trait_group_id], :unique => true, :name => 'by_taxon_and_trait_group'
  end
end
