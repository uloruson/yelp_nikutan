class CreatePostalcodes < ActiveRecord::Migration
  def change
    create_table :postalcodes do |t|
      t.string :code
      t.string :city
      t.string :address

      t.timestamps null: false
    end
  end
end
