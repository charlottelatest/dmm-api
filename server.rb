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

get '/video_metadata' do
  begin
    vid_id = params['vid_id']
    libre_fanza_url = "https://www.libredmm.com/movies/#{vid_id}"
    doc = Nokogiri::HTML(URI.open(libre_fanza_url), nil, Encoding::UTF_8.to_s)

    # Fetch cover url:
    video_cover_url = doc.css(".img-fluid").attr('src')

    # Fetch video title:
    video_title = doc.css("body > main > h1 > span:nth-child(2)").text

    # Fetch released date:
    released_at = doc.css("body > main > div > div.col-md-4 > dl > dd:nth-child(4)").text

    # Fetch trailer video url:
    javdb_url = "https://javdb.com/videos/search_autocomplete.json?q=#{vid_id}"
    uid = JSON.parse(URI.open(javdb_url).read)[0]["uid"]
    javdb_specific_page_url = "https://javdb.com/v/#{uid}"
    javdb_specific_page_doc = Nokogiri::HTML(URI.open(javdb_specific_page_url, 'Cookie' => 'over18=1'))
    trailer_video_url = if javdb_specific_page_doc.css("#preview-video source").attr('src').nil?
      ''
    else
      "https:#{javdb_specific_page_doc.css("#preview-video source").attr('src').text}"
    end
    # Fetch actresses information.
    actress_items = doc.css(".card-title a")
    p actress_items.count

    actresses_name = (if actress_items.count > 1
      actress_stack = []
      actress_items.each do |actress_item|
        actress_stack.push(actress_item.text)
      end
      actress_stack.join("、")
    else
      actress_items.text
    end)

    actresses_name = "暫無演員資訊" if actresses_name.empty?
  {
    video_cover_url: video_cover_url,
    video_title: video_title,
    actresses_name: actresses_name,
    released_at: released_at,
    trailer_video_url: trailer_video_url
  }.to_json
  rescue => exception
    {
      exception: exception
    }.to_json
  end
end

get '/actresses_info' do
  actress_name = params['actress']
  actress_encoded = CGI.escape actress_name
  libre_fanza_url = "https://www.libredmm.com/actresses?fuzzy=#{actress_encoded}"
  doc = Nokogiri::HTML(URI.open(libre_fanza_url), nil, Encoding::UTF_8.to_s)
  fanza_actress_code = doc.css(".card-title > a").each do |item|
    break item.attr('href').split("/")[2] if item.text === actress_name
  end
  dmm_url = "https://actress.dmm.co.jp"
  url = "#{dmm_url}/-/detail/=/actress_id=#{fanza_actress_code}/"
  doc = Nokogiri::HTML(URI.open(url, 'Cookie' => 'age_check_done=1'))
  actress_info_page_url = url
  actress_doc = Nokogiri::HTML(URI.open(actress_info_page_url, 'Cookie' => 'age_check_done=1'))

  # May not find
  actress_id = actress_info_page_url.split("actress_id=")[1].split("/")[0]
  img_url = actress_doc.css('#main-contens img').attr('src')
  birth_date = if actress_doc.css('.p-list-profile__description:nth-child(2)').text.strip != "---"
    birth_date = actress_doc.css('.p-list-profile__description:nth-child(2)').text.strip
    year = birth_date.split("年")[0]
    month = birth_date.split("年")[1].split("月")[0]
    day = birth_date.split("年")[1].split("月")[1].split("日")[0]
    "#{year}/#{month}/#{day}"
  else
    "---"
  end
  spec = actress_doc.css('.p-list-profile__description:nth-child(8)').text.strip.split.join.split("cm").join
  height = spec.scan(/T\d{2}/)[0].nil? ? "---" : spec.scan(/T\d{3}/)[0][1..3]
  bust = spec.scan(/B\d{2,3}/)[0].nil? ? "---" : spec.scan(/B\d{2,3}/)[0][1..3]
  cup = spec.scan(/\([A-Z]{1}/)[0].nil? ? "---" : spec.scan(/\([A-Z]{1}/)[0][1]
  waist = spec.scan(/W\d{2}/)[0].nil? ? "---" : spec.scan(/W\d{2}/)[0][1..2]
  hip = spec.scan(/H\d{2}/)[0].nil? ? "---" : spec.scan(/H\d{2}/)[0][1..2]
  {
    actress_info_page_url: actress_info_page_url,
    fanza_actress_code: fanza_actress_code,
    img_url: img_url,
    birth_date: birth_date,
    height: height,
    cup: cup,
    bust: bust,
    waist: waist,
    hip: hip
  }.to_json
end