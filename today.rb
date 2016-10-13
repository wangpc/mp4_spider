# encoding: utf-8

require 'nokogiri'
require 'json'
require 'net/http'
require 'uri'

def send text, desp, type = :get

	key = File.read('./key_file').strip

	if (text.length > 256) or (desp.length > (1024 * 64))
		raise "error: text length should less than 256 or desp should less than 64k. "
	end

	if type == :get
		uri = URI(URI.encode("http://sc.ftqq.com/#{key}.send?text=#{text}&desp=#{desp}"))
		resp = Net::HTTP.get(uri)
		return resp
	elsif type.downcase == :post
		uri = URI("http://sc.ftqq.com/#{key}.send")
		resp = Net::HTTP.post_form(uri, text: text, desp: desp)
		return resp
	end
end


html_doc = Nokogiri::HTML(`curl -m 5 --retry 10 --retry-delay 2 'http://www.mp4ba.com/index.php?o=today'`)
get_json = {}
get_json[:data] = []
html_doc.xpath('//*[@id="data_list"]/tr/td[3]/a').each do |today_r|
  magnet = Nokogiri::HTML(`curl -m 5 --retry 10 --retry-delay 2 'http://www.mp4ba.com/#{today_r.attr('href')}'`).xpath('//*[@id="magnet"]').attr('href')
  get_json[:data] << {
    name: today_r.text.strip,
    mag: magnet
  }
  sleep 1
end

File.open("./daily_json/#{Time.now.strftime("%Y_%m_%d")}.json", 'a') do |fh|
  fh.puts get_json.to_json
end

movie_list = ""
get_json[:data].each do |gj|
	movie_list += "* #{gj[:name]} \n"
end
# g move list

get_title = "MP4吧今日爬虫任务完成"
get_list = <<-EOS
## 日期
> #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}
## 列表
#{movie_list}
EOS

send get_title, get_list, :post
