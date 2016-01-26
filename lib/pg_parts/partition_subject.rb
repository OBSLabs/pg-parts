module PgParts
  class PartitionSubject < Struct.new(:connection, :table, :strategy)
    def sequence
      steps = [
        create_partition,
        create_rule,
        create_indexes,
        detach_query,
      ].compact.flatten
    end

    def create_partition
      "CREATE TABLE IF NOT EXISTS #{to_attach} () INHERITS (#{table});"
    end

    def create_rule
      %{
        CREATE OR REPLACE RULE #{table}_insert AS
        ON INSERT TO #{table}
        DO INSTEAD
          INSERT INTO #{to_attach} VALUES (new.*)  RETURNING *;
      }
    end

    def create_indexes
      IndexManager.new(connection, table, to_index).create_queries if create_index?
    end

    def detach_query
      if has_children?(to_detach)
        children_to_detach(to_detach).map do |child_to_detach|
          "ALTER TABLE IF EXISTS #{child_to_detach} NO INHERIT #{table};"
        end.join(' ')
      end
    end

    private

    def create_index?
      strategy.index_same_table? || helper.table_exist?(to_index, connection)
    end

    def children
      @children ||= helper.children(table,connection)
    end

    def has_children?(name)
      children_to_detach(name).any?
    end

    def children_list
      children.map { |v| Partition.new(v) }
    end

    def children_to_detach(name)
      current_child = Partition.new(name)
      children_list.select { |child| child.object_date_formatted <= current_child.object_date_formatted }
        .map { |v| v.full_table_name }
    end

    def helper
      PartitionHelper
    end

    def to_detach
      strategy.name(table, strategy.to_remove)
    end

    def to_attach
      strategy.name(table, strategy.current)
    end

    def to_index
      strategy.name(table, strategy.to_index)
    end
  end
end
