class ReportHelper

	attr_reader :tags, :tags_without_user_prefix

  def initialize
    @start_time = nil
    @month_day = nil
    @tags = nil
    @instance_types = []
  end

  def new_hour?(start_time)
    if @start_time != start_time
      @start_time = start_time
      return true
    end
    false
  end

  def new_day?(start_date)
    if @month_day != Date.parse(start_date).mday
      @month_day = Date.parse(start_date).mday
      return true
    end
    false
  end

  def missing_resource_id?(resource_id)
    resource_id.nil? || resource_id.empty? || resource_id == "ResourceId"
  end

  def duration_is_one_hour?(start_date, end_date)
    (Time.parse(end_date) - Time.parse(start_date)) == 3600
  end  

  def load_tags(headers)
    @tags = headers.to_hash.keys.select{ |i| i[/^user:/] }
  end

  def tag_data(line_item)
    rows = {}
    tags.each{|tag| rows[tag] = line_item[tag]}
    rows
  end

  def add_instance_type(instance_type)
    if !instance_type.nil? && instance_type.start_with?("BoxUsage")
      @instance_types << instance_type unless @instance_types.include?(instance_type)
    end
  end

  def instance_type_report
    puts "#{@instance_types.count} unique instance types:"
    puts @instance_types.join("\n")
  end

end
