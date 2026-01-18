# frozen_string_literal: true

class BackfillWishlistsAndAssignWishes < ActiveRecord::Migration[8.0]
  def up
    # 1) Ensure each user has at least one wishlist
    User.in_batches(of: 1000) do |relation|
      relation.select(:id).each do |user|
        next if Wishlist.where(user_id: user.id).exists?

        Wishlist.create!(
          user_id: user.id,
          name: 'Default',
          visibility: :private
        )
      end
    end

    # 2) Assign all existing wishes to user's first wishlist
    Wish.in_batches(of: 1000) do |relation|
      relation.where(wishlist_id: nil).select(:id, :user_id).each do |wish|
        wishlist_id = Wishlist.where(user_id: wish.user_id).order(:id).pick(:id)
        next unless wishlist_id

        Wish.where(id: wish.id).update_all(wishlist_id: wishlist_id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
