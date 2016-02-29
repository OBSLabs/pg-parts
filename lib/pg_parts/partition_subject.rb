module PgParts
  class PartitionSubject < Struct.new(:connection, :table, :strategy)
    def partition_sequence
      steps = [
        create_partition,
        create_rule,
        create_indexes
      ].compact.flatten
    end

    def drop_sequence
      expired_partitions.map do |p|
        "DROP TABLE #{p.full_table_name}; "
      end
    end

    private

    def create_partition
      "CREATE TABLE IF NOT EXISTS #{to_attach} () INHERITS (#{table});"
    end

    def create_rule
      %{ CREATE OR REPLACE RULE #{table}_insert AS
        ON INSERT TO #{table}
        DO INSTEAD
          INSERT INTO #{to_attach} VALUES (new.*)  RETURNING *;
      }
    end

    def create_indexes
      IndexManager.new(connection, table, to_index).create_queries if create_index?
    end

    def expired_partitions
      partitions.select{|p| strategy.expired?(p) }
    end

    def partitions
      @partitions ||= PartitionRepo.new(connection, table).partitions
    end

    def create_index?
      strategy.index_same_table? || helper.table_exist?(to_index, connection)
    end

    def helper
      PartitionHelper
    end

    def to_attach
      strategy.name(table, strategy.current)
    end

    def to_index
      strategy.name(table, strategy.to_index)
    end
  end
end
