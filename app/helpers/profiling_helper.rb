module ProfilingHelper
  class ContinuousSearch
    def search_test(taxon)
      # in the production code, rows is an array.
      # what if it's a hash indexed by otu id
      @continuous_trait_predicate_map = {815 => [], 813 => [], 814 => [], 816 => []}
      # Need to build a matrix of OTU x TRAIT x VALUE x NOTE
      # Start with an array of Otu IDs, ordered by OTU Id
      otu_ids = taxon.otus.pluck(:otu_id)
      # Create a hash populated with Otu IDs.  Sparse
      rows = Hash[otu_ids.map {|v| [v, nil]}]
      ContinuousTraitValue.where(:otu_id => otu_ids).where(:continuous_trait_id => @continuous_trait_predicate_map.keys).includes(:otu, :continuous_trait).each do |continuous_trait_value|

        # loops over the continuous_trait_value
        puts continuous_trait_value.continuous_trait.name
        puts continuous_trait_value.formatted_value

        # continuous_trait_values << {:continuous_trait_id => trait_id, :values => values, :sources => sources, :notes => notes}

        # Insert a value for this OTU in the rows hash if it's empty
        rows[continuous_trait_value.otu_id] ||= {:otu_sort_name => continuous_trait_value.otu.sort_name}
        # TODO: use predicate for filtering

        # TODO: Insert continuous trait value and trait id
        # TODO: Implement match map

      end
      # Cleanup the rows hash - remove anything with no data
      rows.reject!{|k,v| v.nil?}
      # and another hash of otu names to otu ids
      # TODO: Pluck out the OTU names
      # Get the name for each OTU in the rows hash and stuff it back into the hash
      # Should be able to do this with one call to db, once sort_name is stored in db
      #
      Otu.where(:id => rows.keys).sort(:otu_id).each do otu
        rows[otu.id][:sort_name] = otu.sort_name}
      end
      rows.count
    end
  end
end