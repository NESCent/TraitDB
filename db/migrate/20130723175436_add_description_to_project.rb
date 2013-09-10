class AddDescriptionToProject < ActiveRecord::Migration
  def change
    add_column :projects, 'summary_description', :text
    add_column :projects, 'detail_description', :text
    add_column :projects, 'url', :text
    add_column :projects, 'url_text', :text
  end
end
