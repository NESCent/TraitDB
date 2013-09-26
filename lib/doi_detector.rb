class String
  def uri?
    uri = URI.parse(self)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end

  def doi?
    return true if start_with?('http://dx.doi.org/')
    return true if start_with?('doi:')
    false
  end

  def url_for_doi
    return nil unless doi?
    return self if uri?
    # Otherwise, 'doi:...'
    return gsub('doi:','http://dx.doi.org/')
  end
end