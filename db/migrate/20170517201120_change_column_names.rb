class ChangeColumnNames < ActiveRecord::Migration[5.0]
  def change
    rename_column :pins, :path, :from
  end
end
