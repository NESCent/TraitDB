class AddSummarizationMethodToTrait < ActiveRecord::Migration
  def change
    add_column :categorical_traits, :summarization_method, :string, :default => 'collect'
    add_column :continuous_traits, :summarization_method, :string, :default => 'collect'
  end
end
