class FriendshipSerializer
  attr_reader :friendship

  def initialize(friendship)
    @friendship = friendship
  end

  def as_json
    {
      id: friendship.id,
      requester_id: friendship.requester_id,
      addressee_id: friendship.addressee_id,
      status: friendship.status,
      created_at: friendship.created_at,
      updated_at: friendship.updated_at,
      requester: friendship.requester ? UserSerializer.new(friendship.requester).as_json(secure: false) : nil,
      addressee: friendship.addressee ? UserSerializer.new(friendship.addressee).as_json(secure: false) : nil
    }
  end

  def self.collection(friendships)
    friendships.map { |friendship| new(friendship).as_json }
  end
end
