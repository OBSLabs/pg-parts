module PgParts
  module PartitionHelper
    def children(name, connection)
      name = name.to_s
      rel = name
      sql = "
    SELECT pg_inherits.*, c.relname AS child, p.relname AS parent
    FROM
        pg_inherits JOIN pg_class AS c ON (inhrelid=c.oid)
            JOIN pg_class as p ON (inhparent=p.oid)
        where p.relname = '#{rel}'
      "
      connection.exec(sql).to_a.map{|t| t['child']}
    end

    def table_exist?(name, connection)
      name = name.to_s
      rel = name
      sql = "
      SELECT EXISTS(
          SELECT *
          FROM information_schema.tables
          WHERE
            table_schema = 'public' AND
            table_name = '#{rel}'
      )
      "
      connection.exec(sql).to_a.first['exists'] == 't'
    end

    extend self
  end
end
