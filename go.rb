# encoding: utf-8

require 'nokogiri'
require 'json'

def get_mag_from_path path
  puts "*** exec path: #{path} ... "
  page = Nokogiri::HTML(`curl -m 5 --retry 10 --retry-delay 2 'http://www.mp4ba.com/#{path}'`)
  magnet = page.xpath('//*[@id="magnet"]').attr('href')
  puts 'Done'
  # puts "*** magnet is: #{magnet}"
  return magnet
end
(1..122).each do |pn|
  puts "*** exec page #{pn}"
  html_doc = Nokogiri::HTML(`curl -m 5 --retry 10 --retry-delay 2 'http://www.mp4ba.com/index.php?page=#{pn}'`)

  alink = html_doc.xpath('//*[@id="data_list"]/tr/td[3]/a')
  puts "*** current page has #{alink.count} records."
  url_list = []
  alink.each do |al|
    url_list << { name: al.text.strip,
        path: al.attr('href') }
  end
  dump_json = {}
  dump_json[:data] = []
  url_list.each do |record|
    dump_json[:data] << { name: record[:name],
      mag: get_mag_from_path(record[:path])
    }
    sleep 1
  end
  dump_json[:count] = alink.count

  File.open("./page_#{pn}.json", 'a') do |fh|
    fh.puts dump_json.to_json
  end
  sleep 1
end
