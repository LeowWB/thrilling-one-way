# logic for the crawling functionality

require 'open-uri'

module Spider
	
	class Spider

		def initialize
		end

		def spide url

			rv = ""

			open(url) do |f|
				f.each_line do |line|
					rv << line
				end
			end

			return rv
		end
	end
end