require 'time'
module PgParts
  # full_table_name => e.g. 'trackings_20150127'
  class Partition < Struct.new(:full_table_name)
    def base_name
      parts.first
    end

    # works even when hour part is missing.
    def starts_at
      Time.parse(parts.last,"%Y%m%d%h")
    end

    def valid?
      parts.length == 2
    end

    private
    # returns [table name, date as 'YYYYMMDD']
    PATTERN = /^(\w+)_(\d{8}|\d{10})$/
    def parts
      @parts ||= full_table_name.scan(PATTERN).first
    end
  end
end

