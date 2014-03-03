class Analyzer

  def initialize(file)
    @file = file
    @counter = 0
    @tag_changes = TagChanges.new
    @report_helper = ReportHelper.new
    @billing_hour = nil
    @billing_day = nil
  end

  def process

    CSV.foreach(@file, headers: true) do |row|
      @counter += 1

      @report_helper.load_tags(row) if @counter == 1

      # if it doesn't have a resource_id we are not interested.
      next if @report_helper.missing_resource_id?(row['ResourceId'])

      # Check the length of the billing_line_item, should be only 1 hour
      # Some items have the whole month as the duration, we can discard these
      next unless @report_helper.duration_is_one_hour?(row['UsageStartDate'], row['UsageEndDate'])

      create_new_billing_hour if @report_helper.new_hour?(row['UsageStartDate'])
      create_new_billing_day(row['UsageStartDate']) if @report_helper.new_day?(row['UsageStartDate'])

      # Collect all resource_ids with tags ( to create a signature )
      @tag_changes.add_resource(time: row['UsageStartDate'], resource_id: row['ResourceId'], tags: @report_helper.tag_data(row))

      @billing_hour.add_item(BillingItem.new(cost: row['UnBlendedCost'], resource_id: row['ResourceId'], tags: @report_helper.tag_data(row)))

      # For reporting the different instance types
      @report_helper.add_instance_type(row['UsageType'])

    end

    final_report

  end

  def final_report
    @billing_day.display_summary
    @tag_changes.display_changed_tags
    @report_helper.instance_type_report
  end

  private

    def create_new_billing_day(date)
      if !@billing_day.nil? # After the first day
        @billing_day.display_summary
      end
      @billing_day = BillingDay.new(date)
    end

    def create_new_billing_hour
      if !@billing_hour.nil? # After the first hour
        @billing_day.add_hour(@billing_hour)
      end

      @billing_hour = BillingHour.new(@report_helper.tags)
    end
end
