require 'net/http'

# initialize with url
# return path to downloaded file on local file system

module TraitDB
  class Downloader
    def initialize(source_address=nil,dest_path=nil)
      @source = source_address
      @dest = dest_path
    end

    def downloaded_file
      begin
        download
      rescue
        nil
      end

   end

    private

    def get_response_with_redirect(uri)
      r = Net::HTTP.get_response(uri)
      if r.is_a? Net::HTTPRedirection
        r = Net::HTTP.get_response(URI.parse(r.header['location']))
      end
      r
    end

    def download
      uri = URI.parse(@source)
      resp = get_response_with_redirect(uri)
      if resp.is_a? Net::HTTPSuccess
        open(@dest, "wb") do |file|
          file.write(resp.body)
        end
        @dest
      else
        nil
      end
    end

  end
end