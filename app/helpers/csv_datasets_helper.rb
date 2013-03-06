module CsvDatasetsHelper
	def error_messages_for( object )
		render(:partial => 'error_messages', :locals => {:object => object})
	end
end
