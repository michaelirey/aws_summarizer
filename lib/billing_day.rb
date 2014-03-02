class BillingDay

  def initialize(date)
    @date = Date.parse(date)
    @billing_hours = []
  end

  def add_hour(billing_hour)
    @billing_hours << billing_hour
  end

  def display_summary
    calculate_summary
    @summary.sort.each do |tag_header, tags|
      tags.sort.each do |tag, cost|
        puts @date.strftime("%B #{@date.day.ordinalize}") + ", #{tag_header.sub(/^user:/, '')} = #{tag} cost #{format("$%.2f",cost)}"
      end
    end    
  end

  private

    def calculate_summary
      @summary = Hash.new{ |h,k| h[k] = Hash.new{ |h,k| h[k] = 0 } }
      @billing_hours.each do |billing_hour|
        billing_hour.tag_costs.each do |key, values|
          values.each do |tag, cost|
            @summary[key][tag] += cost
          end
        end
      end
    end
end