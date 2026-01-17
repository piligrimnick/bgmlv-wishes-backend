module Wishes
  module Commands
    class CreateWish < ApplicationService
      option :user_id
      option :body, optional: true
      option :url, optional: true
      option :picture, optional: true

      def call
        wish = nil

        Wish.transaction do
          wish = Wish.create!(
            user_id: user_id,
            body: body,
            url: url
          )

          if picture.present?
            filename = picture.respond_to?(:original_filename) ? picture.original_filename : 'image'
            wish.picture.attach(io: picture, filename: "#{wish.id}_#{filename}")
            wish.save
          end
        end

        wish.reload
        Success(wish)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
