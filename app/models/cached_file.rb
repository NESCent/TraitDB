class CachedFile
  def initialize(url=nil)
    @url = url
    @tempfile = Tempfile.new('traitdb-cached-file')
    @downloader = TraitDB::Downloader.new(url, @tempfile.path)
  end

  def file
    return @downloader.downloaded_file
  end
end