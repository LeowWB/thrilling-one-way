# frozen_string_literal: true

require "byebug"
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

  completed_list.each do |c|
    c_seiyuus = get_seiyuu_list ensure_id c
    seiyuu_list.each do |s|
      c_seiyuus.each do |cs|
        puts cs if cs == s
      end
    end
  end
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
  url = URI.encode("https://myanimelist.net/anime/" + id.to_s + "/" + anime_title + "/characters")

  doc = Nokogiri::HTML open url

  elems = doc.css "tr td a"
  return_val = []

  elems.each do |link, x|
    return_val.push link.parent.children[1].content.tr ",","" if
      link["href"]&.include? "/people/" and
      link.parent.children[WHICH_CHILD]&.content == "Japanese"
  end

  return_val.uniq
end

def read_completed_list
  ["danmachi"]
end

main
