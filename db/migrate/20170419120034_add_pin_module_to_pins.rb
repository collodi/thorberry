class AddPinModuleToPins < ActiveRecord::Migration[5.0]
  def change
    add_column :pins, :module, :string
  end
end
