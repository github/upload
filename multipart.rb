# Original lib by Cody Brimhall <mailto:cbrimhall@ucdavis.edu>
# Taken from http://stackoverflow.com/questions/184178/ruby-how-to-post-a-file-via-http-as-multipart-form-data
# Modified by Tekkub for GitHub


require 'rubygems'
require 'mime/types'
require 'cgi'


module Multipart
  class Post
    # We have to pretend like we're a web browser...
    USERAGENT = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6"
    BOUNDARY = "0123456789ABLEWASIEREISAWELBA9876543210"
    CONTENT_TYPE = "multipart/form-data; boundary=#{ BOUNDARY }"
    HEADER = { "Content-Type" => CONTENT_TYPE, "User-Agent" => USERAGENT }

    def self.prepare_query(params)
      fp = []
      files = []

      params.each do |k, v|
        # Are we trying to make a file parameter?
        if v.respond_to?(:path) and v.respond_to?(:read) then
          files.push(FileParam.new(k, v.path, v.read))
        # We must be trying to make a regular parameter
        else
          fp.push(StringParam.new(k, v))
        end
      end

      # Assemble the request body using the special multipart format
      query = (fp + files).collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("")  + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end

  private

  # Formats a basic string key/value pair for inclusion with a multipart post
  class StringParam
    attr_accessor :k, :v

    def initialize(k, v)
      @k = k
      @v = v
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    end
  end

  # Formats the contents of a file or string for inclusion with a multipart
  # form post
  class FileParam
    attr_accessor :k, :filename, :content

    def initialize(k, filename, content)
      @k = k
      @filename = filename
      @content = content
    end

    def to_multipart
      # If we can tell the possible mime-type from the filename, use the
      # first in the list; otherwise, use "application/octet-stream"
      mime_type = MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{ filename }\"\r\n" +
             "Content-Type: #{ mime_type.simplified }\r\n\r\n#{ content }\r\n"
    end
  end
end