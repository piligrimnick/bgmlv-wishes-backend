class ApplicationCollection < Array
  include Rails.application.routes.url_helpers

  def initialize(objects, struct = ApplicationStruct)
    super(objects.map do |object|
      struct.new(object.attributes)
    end)
  end
end
