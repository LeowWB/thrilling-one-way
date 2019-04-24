require 'jikan.rb'
require 'nokogiri'

load 'spider.rb'

WHICH_CHILD = 4

def main
	anime_id = promptAnime
	anime_title = getTitleFromId anime_id
	anime_title.tr! ' ', '_'
	anime_chars_url = "https://myanimelist.net/anime/" + anime_id.to_s + "/" + anime_title + "/characters"
	puts getSeiyuuList URI.encode(anime_chars_url)
end

# prompt user for anime id
def promptAnime
	puts "Enter anime name/id: "
	anime_id = gets.chomp
	puts "Please wait..."
	anime_id = getIdFromRoughName anime_id unless looksValidId? anime_id
	return anime_id
end

def looksValidId? str
	regex = /^[0-9]{1,}$/
	return regex.match str
end

# anime title -> anime id
def getIdFromRoughName name
	query = Jikan::Query.new
	results = query.search name, :anime
	return results.id[0]
end

# anime id -> anime title
def getTitleFromId id
	anime = Jikan::anime id
	return anime.title
end

def getSeiyuuList url

	doc = Nokogiri::HTML open url

	elems = doc.css "tr td a"
	returnVal = []
	
	elems.each do |link, x|
		returnVal.push link.parent.children[1].content.tr ",","" if link["href"] and link["href"].include? "/people/" and
			link.parent.children[WHICH_CHILD] and link.parent.children[WHICH_CHILD].content == "Japanese"
	end

	returnVal.uniq!

	return returnVal
end

main