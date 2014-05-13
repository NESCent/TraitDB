require 'traitdb_import/downloader'
module CsvDatasetsHelper
	def error_messages_for( object )
		render(:partial => 'csv_datasets/error_messages', :locals => {:object => object})
  end
  class CachedFile < Object
    def initialize(url=nil)
      @url = url
      @tempfile = Tempfile.new('traitdb-cached-file')
      @downloader = TraitDB::Downloader.new(url, @tempfile.path)
    end

    def file
      return @downloader.downloaded_file
    end
  end
end
