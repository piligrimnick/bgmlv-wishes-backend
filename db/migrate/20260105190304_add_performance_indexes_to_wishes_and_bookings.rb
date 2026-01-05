class AddPerformanceIndexesToWishesAndBookings < ActiveRecord::Migration[8.0]
  def change
    # Композитный индекс для частых запросов user_wishes и realised_user_wishes
    # Покрывает WHERE user_id = X AND state = Y с сортировкой по created_at
    add_index :wishes, [:user_id, :state, :created_at], 
              name: 'index_wishes_on_user_id_and_state_and_created_at'
    
    # Индекс для быстрых JOIN через has_one :booker, through: :booking
    # Уже есть композитный (user_id, wish_id), но нужен отдельно для JOIN
    add_index :bookings, :user_id, name: 'index_bookings_on_user_id'
  end
end
