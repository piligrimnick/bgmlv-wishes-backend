class ApplicationRepository
  def initialize(gateway:, collection:, struct:)
    @gateway = gateway
    @collection = collection
    @struct = struct
  end

  def all(order: nil, page: nil, per_page: nil)
    scope = order ? gateway.order(order) : gateway

    if page || per_page
      paginate(scope, page, per_page)
    else
      @objects = scope.all
      structurize
    end
  end

  def filter(params, page: nil, per_page: nil)
    scope = gateway.where(params)

    if page || per_page
      paginate(scope, page, per_page)
    else
      @objects = scope
      structurize
    end
  end

  private

  attr_reader :gateway, :collection, :struct, :objects

  def structurize
    collection.new(objects, struct)
  end

  def paginate(scope, page, per_page)
    page = (page || 1).to_i
    per_page = (per_page || 20).to_i

    count_scope = scope.unscope(:includes, :eager_load, :preload)
    total_count = count_scope.count
    
    @objects = scope.limit(per_page).offset((page - 1) * per_page)

    {
      data: structurize,
      metadata: {
        total_count: total_count,
        page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil
      }
    }
  end
end
