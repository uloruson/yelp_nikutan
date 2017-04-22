class AddReviwToShops < ActiveRecord::Migration
  def change
    add_column :shops, :review_count, :integer
  end
end
