class AddcolumnToShop < ActiveRecord::Migration
  def change
    change_table :shops do |t|
      t.string :shop_id
      t.string :shop_provider

      t.string :url
      t.string :image_url
      t.float  :rating
      t.string :rating_img_url

      t.string :postal_code
      t.string :city
    end
    add_index :shops, [:shop_id, :shop_provider], unique: true
  end

end
