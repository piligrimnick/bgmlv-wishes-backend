class CreateWishlists < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :visibility, null: false, default: 1

      t.timestamps
    end
  end
end
