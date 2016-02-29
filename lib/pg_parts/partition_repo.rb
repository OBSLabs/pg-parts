module PgParts
  class PartitionRepo < Struct.new(:connection, :table)
    # to select partition to be moved
    def table_name_pattern
      "#{table}_20%"
    end

    def partitions
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
        ORDER BY table_name;
      }
    end
  end
end
