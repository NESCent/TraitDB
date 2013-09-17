module ProfilingHelper
  class ContinuousSearch
    OPERATORS = { :or => 'or', :and => 'and' }
    def search_test(taxon)
      # in the production code, rows is an array.
      # what if it's a hash indexed by otu id
      @continuous_trait_predicate_map = Hash[[813, 814, 815, 816].map{|v| [v, [] ]}]
      @categorical_trait_category_map = Hash[[136, 137, 138, 139, 140, 141].map{|v| [v, []]}]
      include_references = true
      operator = :or
      remove_empty = true

      # Need to build a matrix of OTU x TRAIT x VALUE x NOTE
      # Start with an array of Otu IDs, ordered by OTU Id
      otu_ids = taxon.otus.pluck(:otu_id)
      # Create a hash populated with Otu IDs.  Sparse
      rows = Hash[otu_ids.map {|v| [v, nil]}]
      # Could split this out to loop over the predicates
      ContinuousTraitValue.where(:otu_id => otu_ids).where(:continuous_trait_id => @continuous_trait_predicate_map.keys).includes(:otu, :continuous_trait, :source_reference).each do |continuous_trait_value|
        trait_id = continuous_trait_value.continuous_trait_id
        value_id = continuous_trait_value.id
        # loops over the continuous_trait_value

        # Insert a value for this OTU in the rows hash if it's empty
        # Lots of building empty hashes/arrays the first time through
        # would be good to abstract this out
        result_row = rows[continuous_trait_value.otu_id] ||= {}
        result_hash = result_row[:continuous] ||= {}
        # matches will be used to indicate whether or not the criteria was met
        # There may be more than one trait value, and each could have a source and notes
        result_arrays = result_hash[trait_id] ||= {
          :values => [], #
          :sources => [], # Array of strings of sources
          :notes => nil, # Array of notes attached to a categorical trait value.
          :value_matches => [] # Array of categorical_trait_value_id => true|false
        }
        result_arrays[:values] << { value_id => continuous_trait_value.formatted_value }
        result_arrays[:sources] << { value_id => continuous_trait_value.source_reference.to_s } if include_references
        # Notes are only stored once per OTUxTrait
        result_arrays[:notes] ||= continuous_trait_value.otu.continuous_trait_notes_text(trait_id)

        predicate = @continuous_trait_predicate_map[trait_id]
        # Record a match if no predicate or if the predicate was matched
        # Note that the database will not be queried again unless there is a predicate
        if predicate.length == 0 || ContinuousTraitValue.where(:id => value_id).where(predicate).count > 0
          result_arrays[:value_matches] << { value_id => true }
        else
          result_arrays[:value_matches] << { value_id => false }
        end
      end
      CategoricalTraitValue.where(:otu_id => otu_ids).where(:categorical_trait_id => @categorical_trait_category_map.keys).includes(:otu, :categorical_trait, :categorical_trait_category, :source_reference).each do |categorical_trait_value|
        trait_id = categorical_trait_value.categorical_trait_id
        value_id = categorical_trait_value.id
        # loops over the categorical_trait_value

        # Insert a value for this OTU in the rows hash if it's empty
        # Lots of building empty hashes/arrays the first time through
        # would be good to abstract this out
        result_row = rows[categorical_trait_value.otu_id] ||= {}
        result_hash = result_row[:categorical] ||= {}
        # matches will be used to indicate whether or not the criteria was met
        # There may be more than one trait value, and each could have a source and notes
        result_arrays = result_hash[trait_id] ||= {
          :values => [], #
          :sources => [], # Array of strings of sources
          :notes => nil, # Array of notes attached to a categorical trait value.
          :value_matches => [] # Array of categorical_trait_value_id => true|false
        }
        result_arrays[:values] << { value_id => categorical_trait_value.formatted_value }
        result_arrays[:sources] << { value_id => categorical_trait_value.source_reference.to_s } if include_references
        # Notes are only stored once per OTUxTrait
        result_arrays[:notes] ||= categorical_trait_value.otu.categorical_trait_notes_text(trait_id)

        category_ids = @categorical_trait_category_map[trait_id]
        # Record a match if no predicate or if the predicate was matched
        # Note that the database will not be queried again unless there is a predicate
        if category_ids.length == 0 || CategoricalTraitValue.where(:id => value_id, :categorical_trait_category_id => category_ids)
          # No category id specified or value matched input criteria
          result_arrays[:value_matches] << {value_id => true }
        else
          result_arrays[:value_matches] << {value_id => false }
        end
      end

      # Filter the rows hash: Remove empty rows and rows that should be left out due to filtering options
      rows.reject!{|otu_id, row_hash| row_hash.nil? || !include_in_results?(otu_id, row_hash, operator, remove_empty)}
      # and another hash of otu names to otu ids
      # Get the name for each OTU in the rows hash and stuff it back into the hash
      #
      Otu.where(:id => rows.keys).each do |otu|
        rows[otu.id][:sort_name] = otu.sort_name
      end
      rows
    end

    # otu_id may not be used
    def include_in_results?(otu_id, row_hash, operator, remove_empty)
      true # Include everything for now
    end
  end
end
