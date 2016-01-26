module PgParts
  # full_table_name => e.g. 'trackings_20150127'
  class Partition < Struct.new(:full_table_name)
    # base table name => e.g. 'trackings'
    def table
      @table ||= parts.first
    end

    # e.g. 20150127
    def date_formatted
      @date_formatted ||= parts.last
    end

    def object_date_formatted
      Date.parse(date_formatted)
    end

    def valid?
      if parts.blank?
        false
      else
        parts.length == 2 && date_formatted.to_i > 20000000 && !!DateTime.parse(date_formatted, "%Y%m%d%H").to_date
      end
    rescue => e
      WarehouseLogger.error(e)
      Bugsnag.notify(e)
      false
    end

    def cloud_directory
      @cloud_directory ||= "/var/cloudfiles/warehouse/#{table}"
    end

    def cloud_file_path
      @cloud_file_path ||= cloud_directory + "/#{full_table_name}.sql.gz"
    end

    def dump_size
      File.size(cloud_file_path).to_i
    end

    private

    PATTERN = /^(\w+)_(\d{8}|\d{10})$/
    # returns [table name, date as 'YYYYMMDD']
    def parts
      @parts ||= full_table_name.scan(PATTERN).first
    end
  end
end

