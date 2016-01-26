module PgParts
  class DailyPartition < BasePartition
    def to_index
      current
    end

    def name(table,t)
      s =  t.strftime('%Y%m%d')
      [table,s].join('_')
    end

    def behavior
      :daily
    end

    def index_same_table?
      true
    end
  end
end
