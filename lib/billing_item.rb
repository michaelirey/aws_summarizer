class BillingItem

  attr_accessor :cost, :resource_id, :tags

  def initialize(resource_id: resource_id, cost: cost, tags: tags)
    @cost = cost
    @resource_id = resource_id
    @tags = tags
  end

end