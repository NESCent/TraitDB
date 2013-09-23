class SimplifySourceReferences < ActiveRecord::Migration
  def up
    remove_index :source_references, :name => "by_ln_fn_year_title_url"
    remove_index :source_references, :name => "index_source_references_on_title"
    remove_index :source_references, :name => "index_source_references_on_url"
    remove_column :source_references, :last_name
    remove_column :source_references, :first_name
    remove_column :source_references, :year
    remove_column :source_references, :url
    rename_column :source_references, :title, :source
    add_index :source_references, ['source'], :name => 'index_source_references_on_source', :length => {'source' => 25}
  end

  def down
    remove_index :source_references, :name => 'index_source_references_on_source'
    rename_column :source_references, :source, :title
    add_column :source_references, :last_name, :string
    add_column :source_references, :first_name, :string
    add_column :source_references, :year, :integer
    add_column :source_references, :url, :string

    add_index "source_references", ["last_name", "first_name", "year", "title", "url"], :name => "by_ln_fn_year_title_url", :length => {"last_name" => 10, "first_name" => 10, "title"=>25, "url" => 25}
    add_index "source_references", ["title"], :name => "index_source_references_on_title", :length => {"title" => 25}
    add_index "source_references", ["url"], :name => "index_source_references_on_url"

  end
end
