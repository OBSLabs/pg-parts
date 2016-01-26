module PgParts
  class StateLoader < Struct.new(:config)
    def self.bootstrap
      options = Parser.parse
      config_yml =  File.read(options[:config])
      config = YAML.load(config_yml).deep_symbolize_keys
      StateLoader.new(config).manager
    end

    def connection
      @connection||=PG::Connection.new(config[:database])
    end

    def manager
      unless @manager
        @manager = PartitionManager.new
        @manager.connection = connection
        hourly.each_pair do |k,v|
          @manager.add!(:hourly, k,v)
        end
        daily.each_pair do |k,v|
          @manager.add!(:daily, k,v)
        end
      end
      @manager
    end

    def tables
      config[:tables]||{}
    end

    def hourly
      tables[:hourly] || {}
    end

    def daily
      tables[:daily] || {}
    end
  end
end
