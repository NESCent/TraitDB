class Taxon < ActiveRecord::Base
  attr_accessible :name, :uri, :import_job, :parent
  belongs_to :project
  belongs_to :iczn_group

  belongs_to :import_job
  has_one :csv_dataset, :through => :import_job
  has_and_belongs_to_many :otus

  has_many :child_taxa, :class_name => 'TaxonAncestor', :foreign_key => 'parent_id'
  has_many :children, :through => :child_taxa, :dependent => :destroy
  
  has_one :parent_taxon, :class_name => 'TaxonAncestor', :foreign_key => 'child_id'
  has_one :parent, :through => :parent_taxon

  has_and_belongs_to_many :trait_groups

  scope :sorted, -> { order('name ASC') }

  scope :sorted_by_iczn, -> { joins(:iczn_group).order('iczn_groups.level ASC') }
  scope :under_iczn_group, lambda{|iczn_group| joins(:iczn_group).where('iczn_groups.level > ?', iczn_group.level)}

  scope :by_project, lambda{|p| where(:project_id => p) unless p.nil?}

  def grouped_categorical_traits
    trait_groups.map{|g| g.categorical_traits.sorted }.flatten
  end

  def grouped_continuous_traits
    trait_groups.map{|g| g.continuous_traits.sorted }.flatten
  end

  def descendants_with_level(dest_iczn_group)
    d = dest_iczn_group.distance(self.iczn_group)
    return [] if d <= 0
    return children.where(:iczn_group_id => dest_iczn_group.id) if d == 1 # if distance is 1, just get the children
    descendants = []
    for x in 1..d
      join_clauses = ["INNER JOIN taxon_ancestors as ta0 on ta0.parent_id = #{self.id}"]
      # now do 1 to n
      for y in 1..(x-1)
        join_clauses << "INNER JOIN taxon_ancestors AS ta#{y} ON ta#{y}.parent_id = ta#{y - 1}.child_id"
      end
      join_clauses << "AND ta#{x - 1}.child_id = taxa.id"
      descendants += Taxon.where(:iczn_group_id => dest_iczn_group.id).joins(join_clauses.join(' '))
    end
    descendants
  end

  def dataset_name
    csv_dataset.csv_file_file_name if csv_dataset
  end
  
  def iczn_group_name
    iczn_group.name if iczn_group
  end
  
  def parent_name
    parent.name if parent
  end

end
