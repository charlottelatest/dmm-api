require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'json'

# jav_db_url = "https://javdb.com/v/n8kRw"
# vid_id_encoded = CGI.escape params['vid_id']
# url = "#{jav_db_url}/-/search/=/searchstr=#{cast_encoded}/"
# doc = Nokogiri::HTML(URI.open(jav_db_url, 'Cookie' => 'over18=1'))
# p doc.css("#preview-video source").attr('src').text
# url = "https://javdb.com/videos/search_autocomplete.json?q=SNIS-002"
# buffer = URI.open(url).read
# result = JSON.parse(buffer)
# p result[0]["uid"]
# cast_name = "栄川乃亜"
# escaped_cast_name = CGI.escape cast_name
# libre_fanza_url = "https://www.libredmm.com/actresses?fuzzy=#{escaped_cast_name}"
# doc = Nokogiri::HTML(URI.open(libre_fanza_url), nil, Encoding::UTF_8.to_s)
# # p doc.css(".card-title > a").first.attr('href').split("/")[2]
# fanza_cast_code = doc.css(".card-title > a").each do |item|
#   break item.attr('href').split("/")[2] if item.text === cast_name
# end

# p fanza_cast_code

vid_id = "MIDE-939"
libre_fanza_url = "https://www.libredmm.com/movies/#{vid_id}"
doc = Nokogiri::HTML(URI.open(libre_fanza_url), nil, Encoding::UTF_8.to_s)
cast_items = doc.css("body > main > dl > dd:nth-child(2) > div > div.card.actress > div > h6 > a")
casts_name = if cast_items.count > 1
  cast_stack = []
  cast_items.each do |cast_item|
    cast_stack.push(cast_item.text)
  end
  cast_stack.join("、")
else
  cast_items.text
end
p casts_name