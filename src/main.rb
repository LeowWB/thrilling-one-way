# frozen_string_literal: true

require "byebug"
require "CGI"
require "jikan.rb"
require "nokogiri"

load "spider.rb"

WHICH_CHILD = 4

def main
  puts "Enter anime name/id: "
  anime_id = gets.chomp
  puts "Please wait..."

  seiyuu_list = get_seiyuu_list ensure_id anime_id
  completed_list = read_completed_list

  overlap_list = []

  completed_list.each_with_index do |c, i|
    puts "Processing #{i + 1} of #{completed_list.length}"

    c_seiyuus = get_seiyuu_list ensure_id c
    seiyuu_list.each do |s|
      c_seiyuus.each do |cs|
        overlap_list << cs if cs == s
      end
    end
  end

  puts overlap_list.uniq
end

def ensure_id name_or_id
  if /^[0-9]{1,}$/.match name_or_id
    name_or_id
  else
    query = Jikan::Query.new
    results = query.search name_or_id, :anime
    results.id[0]
  end
end

def get_seiyuu_list id
  anime_title = (Jikan.anime id).title
  anime_title.tr! " ", "_"
  url = "https://myanimelist.net/anime/" + id.to_s + "/" + CGI.escape(anime_title) + "/characters"

  doc = Nokogiri::HTML URI.open url

  elems = doc.css "tr td a"
  return_val = []

  elems.each do |link|
    return_val.push link.parent.children[1].content.tr ",", "" if
      link["href"]&.include? "/people/" and link.parent.children[WHICH_CHILD]&.content == "Japanese"
  end

  return_val.uniq
end

def read_completed_list
  ["danmachi", "tokyo ghoul"]
end

main
