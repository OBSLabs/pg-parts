module PgParts
  class PartitionRepo < Struct.new(:connection, :table, :behavior)
    # to select partition to be moved
    def table_name_pattern
      behavior == :hourly ? "#{table}_20________" : "#{table}_20%"
    end

    def fetch
      connection.exec(sql)
        .map { |row| Partition.new(row['table_name']) }
        .select(&:valid?)
    end

    def sql
      %{
        SELECT
          table_name
        FROM
          information_schema.tables
        WHERE
            table_schema='public'
          AND
            table_name LIKE '#{table_name_pattern}'
          AND
            table_name not in (#{select_childs_sql})
        ORDER BY table_name;
      }
    end

    def select_childs_sql
      %{
        SELECT c.relname AS child
        FROM
            pg_inherits JOIN pg_class AS c ON (inhrelid=c.oid)
            JOIN pg_class as p ON (inhparent=p.oid)
        WHERE p.relname='#{table}'
      }
    end
  end
end
