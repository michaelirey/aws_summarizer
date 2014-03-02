class TagChanges

  def initialize
    @resources = {}
    @report = []
  end

  def add_resource(time: time, resource_id: resource_id, tags: tags)
    if !@resources[resource_id].nil?
      if tags_changed?(current_tags: @resources[resource_id], new_tags: tags)
        record_change(time: time, resource_id: resource_id, old_tags: @resources[resource_id], new_tags: tags)
      end
    end
    @resources[resource_id] = tags unless tags_nil?(tags)
  end


  def display_changed_tags
    if @report.count != 0
      puts "The following tag changes were detected:"
      @report.each do |change|
        puts "#{change[:time]} instance #{change[:resource_id]} changed from #{change[:old_value]} to #{change[:new_value]}"
      end
    end
  end

  private 
    def tags_changed?(current_tags: current_tags, new_tags: new_tags)
      return false if tags_nil?(new_tags)
      current_tags != new_tags
    end

    def tags_nil?(tags)
      tags.values.each do |tag|
        return false if !tag.nil?
      end
      true
    end

    def record_change(time: time, resource_id: resource_id, old_tags: old_tags, new_tags: new_tags)
      old_value = old_tags.to_a - new_tags.to_a
      new_value = new_tags.to_a - old_tags.to_a
      @report << {time: time, resource_id: resource_id, old_value: old_value, new_value: new_value}
    end


end