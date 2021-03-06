module PgParts
  module TruncateProcessor
    def process!(manager, behavior = :daily)
      manager.find(behavior).each do |subject|
        subject.drop_sequence.each do |cmd|
          puts cmd
          subject.connection.exec cmd
        end
      end.size
    end

    extend self
  end
end
