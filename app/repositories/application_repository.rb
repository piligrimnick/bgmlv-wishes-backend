class ApplicationRepository
  def initialize(gateway:, collection:, struct:)
    @gateway = gateway
    @collection = collection
    @struct = struct
  end

  def all(order: nil)
    @objects = order ? gateway.order(order).all : gateway.all

    structurize
  end

  def filter(params)
    @objects = gateway.where(params)

    structurize
  end

  private

  attr_reader :gateway, :collection, :struct, :objects

  def structurize
    collection.new(objects, struct)
  end
end
