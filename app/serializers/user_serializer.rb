class UserSerializer
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def as_json(secure: false)
    data = {
      id: user.id,
      username: user.username,
      firstname: user.firstname,
      lastname: user.lastname,
      telegram_id: user.telegram_id,
      created_at: user.created_at,
      updated_at: user.updated_at
    }

    data[:email] = user.email if secure
    data[:friendship_id] = user.friendship_id if user.respond_to?(:friendship_id)

    data
  end

  def self.collection(users, secure: false)
    users.map { |user| new(user).as_json(secure: secure) }
  end
end
