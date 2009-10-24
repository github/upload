# Original lib by Cody Brimhall <mailto:cbrimhall@ucdavis.edu>
# Taken from http://stackoverflow.com/questions/184178/ruby-how-to-post-a-file-via-http-as-multipart-form-data
# Modified by Tekkub for GitHub


require 'rubygems'
require 'mime/types'
require 'cgi'


module Multipart
  class Post
    attr_reader :content

    def initialize(params)
      fp = []
      files = []

      params.each do |k,v|
        if v.respond_to?(:path) and v.respond_to?(:read) then
          filename = v.path
          content = v.read
          mime_type = MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]
          fp.push(prepare_param("Content-Type", mime_type.simplified))
          files.push("Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{ filename }\"\r\nContent-Type: #{ mime_type.simplified }\r\n\r\n#{ content }\r\n")
        else
          fp.push(prepare_param(k,v))
        end
      end

      @content = "--#{boundry}\r\n" + (fp + files).join("--#{boundry}\r\n") + "--#{boundry}--"
    end

    def prepare_param(k,v)
      "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    end

    def boundry
      @boundry ||= "#{rand(1000000)}boundryofdoomydoom#{rand(1000000)}"
    end

    def headers
      @headers ||= {
        "Content-Type" => "multipart/form-data; boundary=#{boundry}",
        "User-Agent" => "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6"
      }
    end
  end
end