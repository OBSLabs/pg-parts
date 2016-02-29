module PgParts
  class BasePartition < Struct.new(:limit)
    def current
      @current ||= Time.now
    end

    def to_remove
      current - limit
    end

    def expired?(partition)
      partition.starts_at < to_remove
    end

    def name(table,t)
      raise NotImplementedError
    end

    def to_index
      raise NotImplementedError
    end

    def behavior
      raise NotImplementedError
    end

    def index_same_table?
      raise NotImplementedError
    end
  end
end
