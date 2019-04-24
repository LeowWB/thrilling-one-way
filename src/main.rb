require 'jikan.rb'
require 'nokogiri'

load 'spider.rb'

WHICH_CHILD = 4

def main
	puts "Enter anime name/id: "
	anime_id = gets.chomp
	puts "Please wait..."
	
	seiyuu_list = getSeiyuuList ensureId anime_id	
	completed_list = getCompletedList

	completed_list.each do |c|
		c_seiyuus = getSeiyuuList ensureId c
		seiyuu_list.each do |s|
			c_seiyuus.each do |cs|
				puts cs if cs==s
			end
		end
	end
end

def ensureId nameOrId
	if /^[0-9]{1,}$/.match nameOrId then
		return nameOrId
	else
		query = Jikan::Query.new
		results = query.search nameOrId, :anime
		return results.id[0]
	end
end

def getSeiyuuList id

	anime_title = (Jikan::anime id).title
	anime_title.tr! ' ', '_'
	url = URI.encode("https://myanimelist.net/anime/" + id.to_s + "/" + anime_title + "/characters")
	
	doc = Nokogiri::HTML open url

	elems = doc.css "tr td a"
	return_val = []
	
	elems.each do |link, x|
		return_val.push link.parent.children[1].content.tr ",","" if link["href"] and link["href"].include? "/people/" and
			link.parent.children[WHICH_CHILD] and link.parent.children[WHICH_CHILD].content == "Japanese"
	end

	return_val.uniq!
	return return_val
end

def getCompletedList
	return ["danmachi"]
end

main