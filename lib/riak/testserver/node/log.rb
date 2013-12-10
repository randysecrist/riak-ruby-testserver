module Riak
  class Node
    TS_LAGER_LEVELS = [
                    :debug,
                    :info,
                    :notice,
                    :warning,
                    :error,
                    :critical,
                    :alert,
                    :emergency
                   ]

    def read_console_log(*levels)
      console_log = log + 'console.log'
      if console_log.exist?
        levels = levels.map { |level| expand_log_level(level) }.compact.flatten
        pattern = /(#{levels.map { |level| "\\[#{level}\\]" }.join("|")})/
        console_log.readlines.grep(pattern)
      end
    end

    def expand_log_level(level)
      case level
      when Range
        first = TS_LAGER_LEVELS.index(level.begin.to_sym) || 0
        last = TS_LAGER_LEVELS.index(level.end.to_sym) || -1
        TS_LAGER_LEVELS[first..last]
      when Symbol
        level
      end
    end
  end
end
