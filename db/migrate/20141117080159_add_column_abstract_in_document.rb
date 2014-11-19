class AddColumnAbstractInDocument < ActiveRecord::Migration
  def change
    add_column :documents, :abstract, :string, :limit => 120
  end
end
