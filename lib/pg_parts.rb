Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

app_path = File.expand_path(File.dirname(__FILE__)+"/..")
$LOAD_PATH.unshift(app_path + '/lib')

module PgParts
end
require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require(:default )

class Object
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end

require 'pg_parts/parser'
require 'pg_parts/state_loader'
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
require 'pg_parts/partition_repo'
require 'pg_parts/delete_partition'
require 'pg_parts/truncate_processor'
