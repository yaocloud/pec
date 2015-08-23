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
        puts m.to_s.yellow
      end
      
      def critical(m)
        puts m.to_s.magenta
      end
    end
  end
end
