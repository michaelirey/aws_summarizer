class BillingHour

  attr_reader :tag_costs, :tags

  def initialize(tags)
    @tags = tags
    @tag_costs = Hash.new{ |h,k| h[k] = Hash.new{ |h,k| h[k] = 0 } }
  end

  def add_item(item)
    @tags.each do |tag|
      next if item.tags[tag].nil? # We dont want to add the cost if the item has no tag
      @tag_costs[tag][item.tags[tag]] += item.cost.to_f
    end
  end

end