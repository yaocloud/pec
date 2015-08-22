module Pec
  class Logger
    class << self
      def notice(m)
        puts m.white
      end
      
      def info(m)
        puts m.green
      end
      
      def warning(m)
        puts m.yellow
      end
    end
  end
end
