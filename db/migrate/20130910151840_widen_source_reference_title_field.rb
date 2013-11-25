class WidenSourceReferenceTitleField < ActiveRecord::Migration
  def up
    remove_index "source_references", :name => "by_ln_fn_year_title_url"
    remove_index "source_references", :name => "index_source_references_on_title"
    change_column :source_references, :title, :text
    add_index "source_references", ["last_name", "first_name", "year", "title", "url"], :name => "by_ln_fn_year_title_url",
              :length => {"last_name" => 10, "first_name" => 10, "title"=>25, "url" => 25}
    add_index "source_references", ["title"], :name => "index_source_references_on_title", :length => {"title" => 25}
  end

  def down
    remove_index "source_references", :name => "by_ln_fn_year_title_url"
    remove_index "source_references", :name => "index_source_references_on_title"
    change_column :source_references, :title, :string
    add_index "source_references", ["last_name", "first_name", "year", "title", "url"], :name => "by_ln_fn_year_title_url"
    add_index "source_references", ["title"], :name => "index_source_references_on_title"
  end
end
