require "csv"
require "pry"
require "time"
require "active_support/core_ext/integer/inflections"
require "./lib/report_helper"
require "./lib/billing_day"
require "./lib/billing_hour"
require "./lib/billing_item"
require "./lib/tag_changes"
require "./lib/analyzer.rb"

file = ARGV[0]
puts "File not found" if !File.exists?(file) 

Analyzer.new(file).process