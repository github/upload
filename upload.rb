#!/usr/bin/env ruby

require "form_poster"
require 'net/https'
require "rubygems"
require 'xmlsimple'
# require 'httparty'
require "time"

user  = `git config --global github.user`.strip
token = `git config --global github.token`.strip


raise "No file specified" unless filename = ARGV[0]
raise "Target file does not exist" unless File.size?(filename)


url = URI.parse "https://github.com/"
http = Net::HTTP.new url.host, url.port
http.use_ssl = url.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
res = http.post_form("/tekkub/github-upload/downloads", {
  :file_size => File.size(filename),
  :content_type => 'application/octet-stream',
  :file_name => filename,
  :description => '',
  :login => user,
  :token => token,
})
puts res.body
date = res["Date"]
p data = XmlSimple.xml_in(res.body)


Net::HTTP.start("github.s3.amazonaws.com") do |http|
  headers = {
    "Host" => "github.s3.amazonaws.com",
    # 'Content-Type' => 'text/plain; charset=utf-8',
    # 'Content-Length' => File.size(filename).to_s,
    # 'Accept-Types' => 'text/*',
    # "Filename" => filename,
    "key" => "#{data["prefix"].first}#{filename}",
    "acl" => data["acl"].first,
    'Content-Type' => 'application/octet-stream',
    "policy" => data["policy"].first,
    # "success_action_status" => "201",
    "AWSAccessKeyId" => data["accesskeyid"].first,
    "signature" => data["signature"].first,
    "Authorization" => "AWS #{data["accesskeyid"].first}:#{data["signature"].first}",
    "x-amz-date" => date,
  }
  put_data = File.read(filename)
  response = http.send_request('PUT', "/#{data["prefix"].first}#{filename}", put_data, headers)
  puts "Response #{response.code} #{response.message}:\n#{response.body}"

# res = File.open(filename, "rb") do |file|
#   http.post_multipart("/", {
#     # 'Accept-Types' => 'text/*',
#     # :Filename => filename,
#     :policy => data["policy"].first,
#     # :success_action_status => 201,
#     :key => "#{data["prefix"].first}#{filename}",
#     :AWSAccessKeyId => data["accesskeyid"].first,
#     :signature => data["signature"].first,
#     :acl => data["acl"].first,
#     :file => file
#   })
end
