require 'traitdb_import/downloader'
module CsvDatasetsHelper
	def error_messages_for( object )
		render(:partial => 'csv_datasets/error_messages', :locals => {:object => object})
  end
end
