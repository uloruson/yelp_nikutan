class AddShopsToPhone < ActiveRecord::Migration
  def change
    add_column :Shops, :phone, :string
  end
end
