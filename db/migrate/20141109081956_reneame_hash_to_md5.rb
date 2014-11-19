class ReneameHashToMd5 < ActiveRecord::Migration
  def change
    rename_column :documents, :hash, :md5
  end
end
