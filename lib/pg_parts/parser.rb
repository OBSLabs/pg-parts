module PgParts
  module Parser
    def parse
      options = {config: "config.yml"}
      OptionParser.new do |opts|
        opts.on("-c", "--config CONFIG") do |v|
          options[:config] = v
        end
      end.parse!
      options
    end
    extend self
  end
end
