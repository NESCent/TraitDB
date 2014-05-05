require 'net/http'
require 'uri'

# initialize with url
# return path to downloaded file on local file system

module TraitDB
  class Downloader
    def initialize(uri=nil)
      puts uri
      @file = nil
    end

    def file
      if @file.nil?
        download
      end
      return @file
    end

    private

    def download
      raise 'Not yet implemented'
    end
  end
end