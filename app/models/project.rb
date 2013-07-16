class Project < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :users

  has_many :categorical_traits, :dependent => :destroy
  has_many :continuous_traits, :dependent => :destroy
  has_many :csv_datasets, :dependent => :destroy
  has_many :csv_import_templates, :dependent => :destroy
  has_and_belongs_to_many :iczn_groups # will be important for building search form - to know what groups are in use
  has_many :otus, :dependent => :destroy
  has_many :otu_metadata_fields, :dependent => :destroy
  has_many :taxa, :dependent => :destroy
  has_many :trait_groups, :dependent => :destroy
  has_many :trait_sets, :dependent => :destroy

  scope :sorted, order('name ASC')
end
