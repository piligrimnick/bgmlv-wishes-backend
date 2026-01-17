class CreateFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :friendships do |t|
      t.bigint :requester_id, null: false
      t.bigint :addressee_id, null: false
      t.integer :status, default: 0, null: false  # enum: pending(0), accepted(1), rejected(2)

      t.timestamps
    end

    # Ensure uniqueness: only one friendship per pair (regardless of direction)
    add_index :friendships,
              [:requester_id, :addressee_id],
              unique: true,
              name: 'index_friendships_on_requester_and_addressee'

    # Query optimization indexes
    add_index :friendships, [:addressee_id, :status], name: 'index_friendships_on_addressee_and_status'
    add_index :friendships, [:requester_id, :status], name: 'index_friendships_on_requester_and_status'
    add_index :friendships, [:status, :created_at], name: 'index_friendships_on_status_and_created_at'

    # Foreign keys
    add_foreign_key :friendships, :users, column: :requester_id
    add_foreign_key :friendships, :users, column: :addressee_id
  end
end
