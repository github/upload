#!/usr/bin/env ruby

require "form_poster"
require 'net/https'
require "rubygems"
require 'xmlsimple'


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
p data = XmlSimple.xml_in(res.body)


http = Net::HTTP.new("github.s3.amazonaws.com")
res = File.open(filename, "rb") do |file|
  http.post_multipart("/", {
    # 'Accept-Types' => 'text/*',
    # :Filename => filename,
    :policy => data["policy"].first,
    # :success_action_status => 201,
    :key => "#{data["prefix"].first}#{filename}",
    :AWSAccessKeyId => data["accesskeyid"].first,
    :signature => data["signature"].first,
    :acl => data["acl"].first,
    :file => file
  })
end

puts res.body