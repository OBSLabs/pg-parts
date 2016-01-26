module PgParts
  class IndexManager < Struct.new(:connection, :table, :partition_name)
    def create_queries
      missing_indexes.map do |index|
        index.definition_for(partition_name)
      end
    end

    def missing_indexes
      parent_indexes.select do |i|
        !partition_indexes.map(&:name).any? do |n|
          index_partition_name = i.name_for(partition_name)
          n == index_partition_name || (index_partition_name && n == index_partition_name[0..62])
        end
      end
    end

    def parent_indexes
      @parent_indexes||=find_for(table)
    end

    def partition_indexes
      @partition_indexes||=find_for(partition_name)
    end

    private

    def find_for(t)
      # schemaname='public' is important for specs
      # as campaign_analytics_production and analytics_production are the same
      # in case of RAILS_ENV=test and there are several events/trackings tables
      # living in different schemas
      query = %{
      SELECT
        indexname as name,
        indexdef as definition
      FROM pg_indexes
      WHERE
        tablename = '#{t}'
        and schemaname = 'public'
      }

      connection.exec(query).map do |t|
        Index.new(table.to_s,t['name'], t['definition'])
      end
    end
  end
end
