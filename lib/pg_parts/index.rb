module PgParts
  class Index < Struct.new(:table,:name, :definition)
    def name_for(partition)
      string_for(name, partition)
    end

    def definition_for(partition)
      string_for(definition, partition)
    end
    private

    def string_for(str,t)
      str.to_s.gsub(table,t)
    end
  end
end
