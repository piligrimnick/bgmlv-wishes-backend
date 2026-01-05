class WishesRepository < ApplicationRepository
  def initialize(gateway: Wish, collection: WishesCollection, struct: WishStruct)
    super
  end

  def filter(params, order: 'created_at desc', page: nil, per_page: nil)
    scope = gateway.order(order).where(params)

    if page || per_page
      paginate(scope, page, per_page)
    else
      @objects = scope
      structurize
    end
  end
end
