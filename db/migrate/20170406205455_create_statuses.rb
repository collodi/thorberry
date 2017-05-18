class CreateStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :statuses do |t|
      t.string :alert
      t.integer :ad
      t.float :di
      t.integer :lhl
      t.integer :fcc

      t.timestamps
    end
  end
end
