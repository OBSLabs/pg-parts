module PgParts
  class TruncateProcessor < Struct.new(:manager, :behavior)
    def tables
      @tables ||= manager.find(behavior).map(&:table)
    end

    def self.process!(manager, behavior)
      new(manager,behavior).process!
    end

    def process!
      tables.each { |table| process_table!(table) }
    end

    def process_table!(table)
      detached_partitions(table).each do |partition|
        DeletePartition.new(manager.connection, partition).drop!
      end
    end

    def detached_partitions(table)
      PartitionRepo.new(manager.connection, table, behavior).fetch
    end
  end
end
