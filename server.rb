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

get '/casts_info' do
  dmm_url = "https://actress.dmm.co.jp"
  cast_encoded = CGI.escape params['cast']
  url = "#{dmm_url}/-/search/=/searchstr=#{cast_encoded}/"
  doc = Nokogiri::HTML(URI.open(url, 'Cookie' => 'age_check_done=1'))
  cast_info_page_url = "#{dmm_url}#{doc.css('.p-list-actress__link').attr('href')}"
  cast_doc = Nokogiri::HTML(URI.open(cast_info_page_url, 'Cookie' => 'age_check_done=1'))
  img_url = cast_doc.css('#main-contens img').attr('src')
  birth_date = cast_doc.css('.p-list-profile__description:nth-child(2)').text.strip
  spec = cast_doc.css('.p-list-profile__description:nth-child(8)').text.strip.split.join.split("cm").join
  height = spec.scan(/B\d{2}/)[0].nil? ? "---" : spec.scan(/T\d{3}/)[0][1..3]
  bust = spec.scan(/B\d{2}/)[0].nil? ? "---" : spec.scan(/B\d{2}/)[0][1..2]
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