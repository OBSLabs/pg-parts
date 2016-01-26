Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

app_path = File.expand_path(File.dirname(__FILE__)+"/..")
$LOAD_PATH.unshift(app_path + '/lib')

module PgParts
end
require 'rubygems'
require 'bundler'
Bundler.require(:default )

require 'pg_parts/pg_parts_options_parser'
require 'pg_parts/partition_helper'
require 'pg_parts/partition'
require 'pg_parts/index'
require 'pg_parts/index_manager'
require 'pg_parts/base_partition'
require 'pg_parts/daily_partition'
require 'pg_parts/hourly_partition'
require 'pg_parts/partition_subject'
require 'pg_parts/partition_manager'
require 'pg_parts/partition_processor'
