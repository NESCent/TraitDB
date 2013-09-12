module ProfilingHelper
  class ContinuousSearch
    def search_test(taxon)
      # in the production code, rows is an array.
      # what if it's a hash indexed by otu id
      # and another hash of otu names to otu ids
      @continuous_trait_predicate_map = {815 => [], 813 => [], 814 => [], 816 => []}
      # Need to build a matrix of OTU x TRAIT x VALUE x NOTE
      otu_ids = taxon.otus.pluck(:otu_id)
      ContinuousTraitValue.where(:otu_id => otu_ids).where(:continuous_trait_id => @continuous_trait_predicate_map.keys).includes(:otu, :continuous_trait).each do |continuous_trait_value|
        # loops over the continuous_trait_value
        puts continuous_trait_value.continuous_trait.name
        puts continuous_trait_value.formatted_value
        #puts continuous_trait_value.otu.name # This still generates a select statement every time
        # need to have a data structure of rows

      end
      if false
      taxon.otus.each do |otu|
        # Start with a hash containing the OTU
        # This row will only be included in the output set if the criteria is met
        row = { :otu => otu, :sort_name => otu.name }
        match_map = {:continuous => [], :categorical => []}
        # for each Otu in the list, see if it has the specified trait values

        ### Continuous Trait Search
        continuous_trait_values = []
        @continuous_trait_predicate_map.each do |trait_id, predicate_array|
          matched_values = otu.continuous_trait_values.where(:continuous_trait_id => trait_id)
          coded_count = matched_values.count
          # predicate_array is an object ready to be dropped into a where() call.
          # The operator (and/or) has already been added to the query
          matched_values = matched_values.where(predicate_array)
          matched_count = matched_values.count
          unless matched_values.empty?
            values = matched_values.map{|continuous_trait_value| continuous_trait_value.formatted_value}
            sources = matched_values.map{|continuous_trait_value| continuous_trait_value.source_reference.to_s }
            # Notes only included if there is a result
            notes = otu.continuous_trait_notes_text(trait_id)
            if notes
              # This trait has a note.  Add a notes column unless one already exists
              continuous_trait_notes_ids << trait_id unless continuous_trait_notes_ids.include? trait_id
            end
            continuous_trait_values << {:continuous_trait_id => trait_id, :values => values, :sources => sources, :notes => notes}
          end
          # requested count is 1 because predicates for continuous are either met or not met
          match_map[:continuous] << {:trait_id => trait_id, :coded_count => coded_count,
                                     :requested_count => 1,
                                     :matched_count => matched_count}
        end
        row[:continuous_trait_values] = continuous_trait_values # may be an empty array
      end
      end
    end
  end
end