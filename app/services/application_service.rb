class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result]

  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end
end
