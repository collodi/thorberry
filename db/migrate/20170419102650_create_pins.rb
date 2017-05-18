class CreatePins < ActiveRecord::Migration[5.0]
  def change
    create_table :pins do |t|
      t.string :stage
      t.string :path
      t.string :pinval

      t.timestamps
    end
  end
end
