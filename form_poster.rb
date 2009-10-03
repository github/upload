
require "net/http"
require "rubygems"
require 'mime/types'


module Net
  class HTTP
    def urlencode(str)
      str.gsub(/[^a-zA-Z0-9_\.\-]/n) {|s| sprintf('%%%02x', s[0]) }
    end

    def post_form(path, params)
      req = Net::HTTP::Post.new(path)
      req.body = params.map {|k,v| "#{urlencode(k.to_s)}=#{urlencode(v.to_s)}" }.join('&')
      req.content_type = 'application/x-www-form-urlencoded'
      self.request req
    end

    def post_multipart(path, params)
      boundary = "tek-boundary-of-doomy-doom"
      query = "--#{boundary}--\r\n"
      query << params.map do |k,v|
        if v.respond_to?(:read)
          # query << %Q|\r\n--#{boundary}\r\nContent-Disposition: form-data; name="#{urlencode(k.to_s)}"; filename="#{v.path}"\r\nContent-Transfer-Encoding: binary\r\nContent-Type: #{MIME::Types.type_for(v.path)}\r\n\r\n#{v.read}\r\n|
          [
            %Q|Content-Disposition: form-data; name="#{urlencode(k.to_s)}"; filename="#{v.path}"|,
            "Content-Transfer-Encoding: binary",
            "Content-Type: application/octet-stream",
            "",
            v.read
          ].join("\r\n")
        else
          [%Q|Content-Disposition: form-data; name="#{urlencode(k.to_s)}"|, "", v].join("\r\n")
        end
      end.join("\r\n--#{boundary}--\r\n")
      query << "\r\n--#{boundary}--"

      puts query
      self.post(path, query, {"Content-type" => "multipart/form-data, boundary=#{boundary} "})
    end
  end
end






