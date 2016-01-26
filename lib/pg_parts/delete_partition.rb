module PgParts
  class DeletePartition < Struct.new(:connection, :partition)
    def drop!
      connection.exec(drop_query)
    end

    def drop_query
      "DROP TABLE #{partition.full_table_name};"
    end
  end
end
