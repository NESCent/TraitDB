class AddProjectForeignKeys < ActiveRecord::Migration
  def change
    # Models that belong_to projects
    [:categorical_traits, :continuous_traits, :otus, :otu_metadata_fields,
     :taxa, :trait_groups, :trait_sets].each do |table|
      add_column table, :project_id, :integer, :null => false, :default => 1
      add_index table, :project_id
    end
    # Models with has_and_belongs_to_many projects
    # has_and_belongs_to_many :iczn_groups # will be important for building search form - to know what groups are in use
    create_table 'iczn_groups_projects' do |t|
      t.integer :iczn_group_id
      t.integer :project_id
    end
    add_index 'iczn_groups_projects', :iczn_group_id
    add_index 'iczn_groups_projects', :project_id
  end
end
