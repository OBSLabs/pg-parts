module PgParts
  class HourlyPartition < BasePartition
    def to_index
      current - 3600
    end

    def name(table,t)
      s =  t.strftime('%Y%m%d%H')
      [table,s].join('_')
    end

    def behavior
      :hourly
    end

    def index_same_table?
      false
    end
  end
end
