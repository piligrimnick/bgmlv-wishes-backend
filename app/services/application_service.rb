class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result]

  def self.call(*, **, &)
    new(*, **).call(&)
  end
end
