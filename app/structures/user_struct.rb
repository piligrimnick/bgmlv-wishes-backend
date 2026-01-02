class UserStruct < ApplicationStruct
  attribute :id, Types::Integer.optional
  attribute :email, Types::String.optional
  attribute :username, Types::String.optional
  attribute :firstname, Types::String.optional
  attribute :lastname, Types::String.optional

  def secure_attributes
    attributes.except(:email)
  end
end
