require 'yaml'
class Object
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end

module PgParts
  module PgPartsOptionsParser
    class Config < Struct.new(:data)
      def connection
        @connection||=PG::Connection.new(data[:database])
      end

      def manager
        unless @manager
          @manager = PartitionManager.new
          @manager.connection = connection
          hourly.each_pair{ |k,v| @manager.add!(:hourly, k,v) }
          daily.each_pair{ |k,v| @manager.add!(:daily, k,v) }
        end
        @manager
      end

      def tables
        data[:tables]||{}
      end

      def hourly
        tables[:hourly] || {}
      end

      def daily
        tables[:daily] || {}
      end
    end
    def parse
      options = {config: "config.yml"}
      OptionParser.new do |opts|
        opts.on("-c", "--config CONFIG") do |v|
          options[:config] = v
        end
      end.parse!
      options
    end

    def state
      options_to_config(parse)
    end

    def options_to_config(options)
      hash = YAML.load(File.read(options[:config]))
      Config.new(hash.deep_symbolize_keys)
    end
    extend self
  end
end
