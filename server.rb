require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'cgi'

before do
  content_type :json
end

get '/' do
  'Welcome'
end

# get '/trailers' do
#   begin
#     vid_id_encoded = CGI.escape params['vid_id']
#     url = "https://javdb.com/videos/search_autocomplete.json?q=#{vid_id_encoded}"
#     buffer = URI.open(url).read
#     result = JSON.parse(buffer)
#     uid = result[0]["uid"]
#     jav_db_url = "https://javdb.com/v/#{uid}"
#     p jav_db_url
#     doc = Nokogiri::HTML(URI.open(jav_db_url, 'Cookie' => 'over18=1'))
#     {
#       tailer_url: "https:#{doc.css("#preview-video source").attr('src').text}"
#     }.to_json
#   rescue => exception
#     {
#       reason: exception,
#       error_msg: "Trailer does't exists.",
#       status_code: "404"
#     }.to_json
#   end
# end
# "https://www.dmm.co.jp/mono/dvd/-/list/=/article=actress/format=dvd/id=1044864/sort=review_rank/"
get '/casts_info' do
  cast_name = params['cast']
  cast_encoded = CGI.escape cast_name
  libre_fanza_url = "https://www.libredmm.com/actresses?fuzzy=#{cast_encoded}"
  doc = Nokogiri::HTML(URI.open(libre_fanza_url), nil, Encoding::UTF_8.to_s)
  fanza_cast_code = doc.css(".card-title > a").each do |item|
    break item.attr('href').split("/")[2] if item.text === cast_name
  end
  dmm_url = "https://actress.dmm.co.jp"
  url = "#{dmm_url}/-/detail/=/actress_id=#{fanza_cast_code}/"
  doc = Nokogiri::HTML(URI.open(url, 'Cookie' => 'age_check_done=1'))
  cast_info_page_url = url
  cast_doc = Nokogiri::HTML(URI.open(cast_info_page_url, 'Cookie' => 'age_check_done=1'))

  # May not find
  cast_id = cast_info_page_url.split("actress_id=")[1].split("/")[0]
  img_url = cast_doc.css('#main-contens img').attr('src')
  birth_date = if cast_doc.css('.p-list-profile__description:nth-child(2)').text.strip != "---"
    birth_date = cast_doc.css('.p-list-profile__description:nth-child(2)').text.strip
    year = birth_date.split("年")[0]
    month = birth_date.split("年")[1].split("月")[0]
    day = birth_date.split("年")[1].split("月")[1].split("日")[0]
    "#{year}/#{month}/#{day}"
  else
    "---"
  end
  spec = cast_doc.css('.p-list-profile__description:nth-child(8)').text.strip.split.join.split("cm").join
  height = spec.scan(/T\d{2}/)[0].nil? ? "---" : spec.scan(/T\d{3}/)[0][1..3]
  bust = spec.scan(/B\d{2,3}/)[0].nil? ? "---" : spec.scan(/B\d{2,3}/)[0][1..3]
  cup = spec.scan(/\([A-Z]{1}/)[0].nil? ? "自行目測" : spec.scan(/\([A-Z]{1}/)[0][1]
  waist = spec.scan(/W\d{2}/)[0].nil? ? "---" : spec.scan(/W\d{2}/)[0][1..2]
  hip = spec.scan(/H\d{2}/)[0].nil? ? "---" : spec.scan(/H\d{2}/)[0][1..2]
  {
    cast_info_page_url: cast_info_page_url,
    img_url: img_url,
    birth_date: birth_date,
    height: height,
    cup: cup,
    bust: bust,
    waist: waist,
    hip: hip
  }.to_json
end