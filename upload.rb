#!/usr/bin/env ruby

require "form_poster"
require 'net/https'
require "rubygems"
require 'xmlsimple'
require "time"
require "multipart"


user  = `git config --global github.user`.strip
token = `git config --global github.token`.strip
raise "Cannot find login credentials" if user.empty? || token.empty?


filename = "rand#{rand(10000000)}.zip"
`cp upload.rb #{filename}`
# `cp LimeChat.app.zip #{filename}`

# raise "No file specified" unless filename = ARGV[0]
raise "Target file does not exist" unless File.size?(filename)


# Get the info we need from GitHub to post to S3
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
date = res["Date"]
data = XmlSimple.xml_in(res.body)


# Prepare post to S3
mp = Multipart::Post.new(
  "key" => "#{data["prefix"].first}#{filename}",
  "Filename" => filename,
  "policy" => data["policy"].first,
  "AWSAccessKeyId" => data["accesskeyid"].first,
  "signature" => data["signature"].first,
  "acl" => data["acl"].first,
  "file" => File.new(filename),
  "success_action_status" => 201
)

# Make form post now
Net::HTTP.start("github.s3.amazonaws.com") do |http|
  res = http.post("/", mp.content, mp.headers)
  raise "File upload failed" unless res.class == Net::HTTPCreated
end

