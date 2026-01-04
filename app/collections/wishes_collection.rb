class WishesCollection < ApplicationCollection
  include Rails.application.routes.url_helpers

  def default_url_options
    Rails.application.routes.default_url_options
  end

  def initialize(objects, struct = WishStruct)
    objects = objects.map do |object|
      attributes = object.attributes
      attributes[:user] = UserStruct.new(object.user.attributes).secure_attributes
      if object.booking.present?
        attributes[:booking] = BookingStruct.new(object.booking.attributes).to_h
        attributes[:booker] = UserStruct.new(object.booker.attributes).to_h
      end
      attributes[:picture_url] = rails_blob_path(object.picture, only_path: true) if object.picture.attached?

      struct.new(attributes)
    end
    super
  end
end
