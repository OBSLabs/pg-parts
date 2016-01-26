module PgParts
  class PartitionManager
    attr_accessor :connection

    def add!(behavior, table, period)
      klass = { daily: DailyPartition, hourly: HourlyPartition }[behavior]
      strategy = klass.new(period)
      obj  = PartitionSubject.new(connection, table, strategy)
      subjects<<obj
      self
    end

    # don't want to make it singleton as it's makes much harder to test state.
    # see no problem in creating several instances.
    def self.instance
      @instance||=PartitionManager.new
    end

    def subjects
      @subject||=[]
    end

    def find(behavior = :daily)
      subjects.select{|t| t.strategy.behavior == behavior }
    end

    def subjects=(v)
      @subjects=v
    end
  end
end
