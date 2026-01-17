class BookingSerializer
  attr_reader :booking

  def initialize(booking)
    @booking = booking
  end

  def as_json
    {
      id: booking.id,
      user_id: booking.user_id,
      wish_id: booking.wish_id,
      created_at: booking.created_at,
      updated_at: booking.updated_at
    }
  end

  def self.collection(bookings)
    bookings.map { |booking| new(booking).as_json }
  end
end
