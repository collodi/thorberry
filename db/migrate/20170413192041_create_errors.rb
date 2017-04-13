class CreateErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :errors do |t|
      t.string :msg
      t.string :code

      t.timestamps
    end
  end
end
