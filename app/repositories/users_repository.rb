class UsersRepository < ApplicationRepository
  def initialize(gateway: User, collection: UsersCollection, struct: UserStruct)
    super
  end

  def inactive
    @objects = User.left_outer_joins(:wishes, :bookings)
                   .where(wishes: { id: nil }, bookings: { id: nil })
    structurize
  end
end
