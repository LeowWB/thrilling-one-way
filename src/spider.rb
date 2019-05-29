# frozen_string_literal: true

# logic for the crawling functionality

require "open-uri"

module Spider
  # used for spiding urls
  class Spider
    def spide url
      rv = ""

      URI.open(url) do |f|
        f.each_line do |line|
          rv << line
        end
      end

      rv
    end
  end
end
