require 'yaml'

module TraitDB
  class ImportTemplate
    attr_reader :template # The hash containing template values
    def initialize(path=nil)
      @template_file = path
      if file_usable?
        read_template
      else
        @template_file = nil
        raise "Unable to load template file at #{path}"
      end
    end
    private

    def file_usable?
      return false unless @template_file
      return false unless File.exists?(@template_file)
      return false unless File.readable?(@template_file)
      return true
    end

    def read_template
      @template = YAML.load_file(@template_file)
    end
    
  end
end

