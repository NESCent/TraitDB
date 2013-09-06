class SearchController < ApplicationController
  before_filter :set_project
  OPERATORS = { :or => 'or', :and => 'and' }
  def index
    @iczn_groups = @project.iczn_groups.sorted.select{|group| group.taxa.count > 0}

    @trait_groups = []
    @trait_types = [['Categorical', :categorical], ['Continuous', :continuous]]
    @trait_names = {:categorical => CategoricalTrait.by_project(@project).sorted, :continuous => ContinuousTrait.by_project(@project).sorted }
    @categorical_trait_values = categorical_trait_values_for_trait(@trait_names[:categorical].first)
    # Trait set support
    @trait_set_levels = @project.trait_sets.levels
  end

  def list_taxa # needs iczn_group_id and parent_ids
    iczn_group_id = params[:iczn_group_id]
    parent_ids = params[:parent_ids]
    @taxa_list = taxa_in_iczn_group_with_parents(iczn_group_id, parent_ids)
    render :json => @taxa_list
  end

  # TODO: send trait set ids as params and filter on them!
  def list_categorical_trait_names # needs taxon_ids and optionally trait_set_ids
    @categorical_trait_names = []
    @project.taxa.where(:id => params[:taxon_ids]).each do |taxon|
      @categorical_trait_names = @categorical_trait_names | taxon.grouped_categorical_traits
    end
    render :json => @categorical_trait_names
  end

  def list_continuous_trait_names # needs taxon_ids
    @continuous_trait_names = []
    @project.taxa.where(:id => params[:taxon_ids]).each do |taxon|
      @continuous_trait_names = @continuous_trait_names | taxon.grouped_continuous_traits
    end
    render :json => @continuous_trait_names
  end

  def list_categorical_trait_values
    @trait_values = categorical_trait_values_for_trait(params[:trait_id])
    render :json => @trait_values
  end

  def list_trait_sets # needs parent_trait_set_id, may be nil for project's root trait sets
    @trait_sets = @project.trait_sets.where(:parent_trait_set_id => params[:parent_trait_set_id])
    render :json => @trait_sets
  end

  def results
    @trait_operator = params['trait_operator']
    # trait_operator must be 'and' or 'or'.
    # This string is used in database queries and defaults to 'or'
    unless OPERATORS.values.include? @trait_operator
      @trait_operator = OPERATORS[:or]
    end
    @results = {}
    @results[:columns] = {} # start with an empty hash for output display columns

    analyze_lowest_requested_taxa # populates @lowest_requested_taxa, @selected_taxon_ids, and @results[:columns][:iczn_groups]
    # analyze_lowest_requested_taxa must come before assemble_trait_filters
    assemble_trait_filters # populates @categorical_trait_category_map and @continuous_trait_predicate_map

    # Output columns should include chosen continuous traits
    @results[:columns][:continuous_traits] = @project.continuous_traits.where(:id => @continuous_trait_predicate_map.keys).map do |continuous_trait|
      {:id => continuous_trait.id, :name => continuous_trait.name}
    end

    # output columns should include chosen categorical traits
    @results[:columns][:categorical_traits] = @project.categorical_traits.where(:id => @categorical_trait_category_map.keys).map do |categorical_trait|
      {:id => categorical_trait.id, :name => categorical_trait.name}
    end

    # Arrays to hold ids of the traits where notes were recorded
    categorical_trait_notes_ids = [] # categorical_trait_ids of traits where notes were found
    continuous_trait_notes_ids = [] # continuous_trait_ids of traits where notes were found

    # Array to hold the metadata field names attached to the data we found
    otu_metadata_field_names = []

    rows = []


    # At this point, we'll have a list of the most specific taxa requested at each level
    @lowest_requested_taxa.each do |lowest_requested_taxon|
      lowest_requested_taxon.otus.each do |otu|
        # Start with a hash containing the OTU
        # This row will only be included in the output set if the criteria is met
        row = { :otu => otu, :sort_name => otu.name }
        match_map = {:continuous => [], :categorical => []}
        # for each Otu in the list, see if it has the specified trait values
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

        categorical_trait_values = []
        @categorical_trait_category_map.each do |trait_id, category_ids|
          requested_count = category_ids.count
          matched_values = otu.categorical_trait_values.where(:categorical_trait_id => trait_id)
          coded_count = matched_values.count
          # category_ids is an array of the category values selected on the form.
          # If it is empty, then the user did not specify any category IDs to filter on, so include everything
          unless category_ids.empty?
            matched_values = matched_values.where(:categorical_trait_category_id => category_ids)
          end
          matched_count = matched_values.count
          unless matched_values.empty?
            values = matched_values.map{|categorical_trait_value| categorical_trait_value.formatted_value }
            sources = matched_values.map{|categorical_trait_value| categorical_trait_value.source_reference.to_s }
            notes = otu.categorical_trait_notes_text(trait_id)
            if notes
              # This trait has a note.  Add a notes column unless one already exists
              categorical_trait_notes_ids << trait_id unless categorical_trait_notes_ids.include? trait_id
            end

            categorical_trait_values << {:categorical_trait_id => trait_id, :values => values, :sources => sources, :notes => notes }
          end
          match_map[:categorical] << {:trait_id => trait_id, :coded_count => coded_count,
                                      :requested_count => requested_count,
                                      :matched_count => matched_count}
        end
        row[:categorical_trait_values] = categorical_trait_values # may be an empty array

        # for the case of AND, make sure the matched count is >= the coded count
        # Only the sums of these are used, so the intermediate hash is unnecessary
        total_categorical_requested = match_map[:categorical].map{|t| t[:requested_count]}.reduce(:+) || 0
        total_categorical_matched = match_map[:categorical].map{|t| t[:matched_count]}.reduce(:+) || 0
        total_categorical_coded = match_map[:categorical].map{|t| t[:coded_count]}.reduce(:+) || 0
        total_continuous_requested = match_map[:continuous].map{|t| t[:requested_count]}.reduce(:+) || 0
        total_continuous_matched = match_map[:continuous].map{|t| t[:matched_count]}.reduce(:+) || 0
        total_continuous_coded = match_map[:continuous].map{|t| t[:coded_count]}.reduce(:+) || 0

        if @trait_operator == OPERATORS[:and]
          # For AND, include this row only if the total number of trait filters requested meets the number of trait values found
          if total_categorical_matched == total_categorical_requested && total_continuous_matched >= total_continuous_requested
            rows << row
          end
        else
          # For OR, include if any values matched or if include all data was selected but nothing was coded
          if total_categorical_matched > 0 || total_continuous_matched > 0 || (params['only_rows_with_data'].nil? && total_categorical_coded == 0 && total_continuous_coded == 0)
            rows << row
          end
        end
        # add metadata field names from the included OTU
        row[:metadata] = otu.metadata_hash
        otu_metadata_field_names |= row[:metadata].keys
        # add taxonomy to the row, so that the view doesn't have to look up OTU relationships
        taxonomy = {}
        otu.taxa.each{|t| taxonomy[t.iczn_group_id] = t.name}
        row[:taxonomy] = taxonomy
      end # otu
    end
    rows.sort! {|a,b| a[:sort_name] <=> b[:sort_name]}

    @results[:columns][:categorical_trait_notes_ids] = categorical_trait_notes_ids
    @results[:columns][:continuous_trait_notes_ids] = continuous_trait_notes_ids
    @results[:columns][:otu_metadata_field_names] = otu_metadata_field_names

    # data to return to view
    # @results[:columns] is a hash with keys :categorical_traits and :continuous_traits
    @results[:rows] = rows # rows is an array of hashes.  Each hash has :otu, :categorical_trait_values, and :continuous_trait_values
    @results[:include_references] = !params['include_references'].nil?

    respond_to do |format|
      format.csv do
        filename = "results-#{Time.now.strftime("%Y%m%d")}.csv"
        if request.env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers["Content-type"] = "text/plain"
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
          headers['Expires'] = "0"
        else
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
        end
      end
      format.html
    end
  end

  def show_trait_list
    @categorical_traits = @project.categorical_traits.sorted
    @continuous_traits = @project.continuous_traits.sorted
  end

  private

  # Extracts the taxon ids and the lowest requested taxa from the taxonomy portion of the search form
  def analyze_lowest_requested_taxa
    # The requested taxon filters have parameter names that correspond to IcznGroup names.
    # The values are the Taxon IDs
    sorted_groups_requested = @project.iczn_groups.sorted.where(:name => params.keys)
    valid_group_names = @project.iczn_groups.sorted.pluck(:name)
    @results[:columns][:iczn_groups]= sorted_groups_requested.map{|group| {:name => group.name, :id => group.id}}

    # An example params hash looks like this
    # "{"htg"=>{"0"=>"2601", "2"=>"2601"}, "order"=>{"0"=>"2602", "2"=>"2602"}, "family"=>{"0"=>"2603", "2"=>"2607"}, "genus"=>{"0"=>"2625", "2"=>"2612"}, "species"=>{"0"=>"2623", "2"=>"2613"}, "trait_types"=>{"0"=>""}, "categorical_trait_name"=>{"0"=>""}, "categorical_trait_values"=>{"0"=>""}, "continuous_trait_name"=>{"0"=>""}, "continuous_trait_value_predicates"=>{"0"=>""}, "continuous_trait_entries"=>{"0"=>""}, "include_references"=>"on", "controller"=>"search", "action"=>"results"}"

    indices = []

    params.each do |pk, pv|
      next unless valid_group_names.include? pk
      # pk is one of 'htg','order',etc...
      # pv looks like {"0"=>"2602", "2"=>"2607"}
      # "0" and "2" are integers in string format, and these indices may not be consecutive
      indices += pv.keys.map{|n| n.to_i}
    end
    indices.sort!.uniq!

    @lowest_requested_taxa = []
    @selected_taxon_ids = []

    indices.each do |index|
      lowest_requested_taxon = nil
      sorted_groups_requested.each do |group|
        taxon_id_str = params[group.name][index.to_s]
        unless taxon_id_str.nil? || taxon_id_str.empty?
          @selected_taxon_ids << taxon_id_str.to_i
          lowest_requested_taxon = @project.taxa.find(taxon_id_str.to_i)
        end
      end
      @lowest_requested_taxa << lowest_requested_taxon if lowest_requested_taxon
    end
  end

  # extracting functionality out of search to deliver a list of traits
  def assemble_trait_filters
    @continuous_trait_predicate_map = {} # map of continuous_trait_ids to arrays of predicates and values
    @categorical_trait_category_map = {} # Map of categorical_trait_ids to arrays of categorical_trait_category_ids
    # if All traits specified, find them all!
    if params['select_all_traits'] # Checkbox, only exists in params if checked
      # Need the selected taxon_ids
      # First get all the traits from the selected taxonomy
      continuous_traits, categorical_traits,   = [],[]
      @project.taxa.where(:id => @selected_taxon_ids).each do |taxon|
        continuous_traits = continuous_traits | taxon.grouped_continuous_traits
        categorical_traits = categorical_traits | taxon.grouped_categorical_traits
      end
      # selecting all traits - do not apply predicates or values
      continuous_traits.each{|trait| @continuous_trait_predicate_map[trait.id] = [] }
      categorical_traits.each{|trait| @categorical_trait_category_map[trait.id] = []}
      # done
    else
      # select all was not checked, create filters based on form selections
      continuous_trait_filters = {}
      # Continuous Trait Values
      continuous_trait_indices = params['trait_type'].select{|k,v| v == 'continuous'}.keys
      unless continuous_trait_indices.empty?
        params['trait_name'].select{|k,v| k.in?(continuous_trait_indices)}.reject{|k,v| v.empty?}.each do |k,v|
          trait_id = Integer(v)
          # This block is invoked for each filter on the search form
          # Multiple filters may reference the same trait, so keep the values/predicates for each trait together
          if continuous_trait_filters[trait_id].nil?
            continuous_trait_filters[trait_id] = {:predicates => [], :values => []}
          end
          predicates = continuous_trait_filters[trait_id][:predicates]
          values = continuous_trait_filters[trait_id][:values]

          # Check for the equals/less than/etc
          # get the predicate for this row
          if params['trait_values'][k] && params['trait_entries'][k]
            unless params['trait_entries'][k].blank?
              field_value = Float(params['trait_entries'][k])
              case params['trait_values'][k]
                when 'gt'
                  predicates << 'value > ?'
                  values << field_value
                when 'lt'
                  predicates << 'value < ?'
                  values << field_value
                when 'eq'
                  predicates << 'value = ?'
                  values << field_value
                when 'ne'
                  predicates << 'value != ?'
                  values << field_value
              end
            end
          end
          continuous_trait_filters[trait_id][:predicates] = predicates
          continuous_trait_filters[trait_id][:values] = values
        end
      end

      # Convert to one predicate, and use the operator
      # The argument to a where() call should look like this: where(['value > ? AND value < ?', 1, 2])
      # joining the predicates provides the 'value > ? AND value < ?'
      # The * in front of the values array converts it to varargs
      continuous_trait_filters.each do |trait_id, filter|
        @continuous_trait_predicate_map[trait_id] = [filter[:predicates].join(" #{@trait_operator} "), *filter[:values]]
      end

      # Categorical Trait Values
      categorical_trait_indices = params['trait_type'].select{|k,v| v == 'categorical'}.keys
      unless categorical_trait_indices.empty?
        params['trait_name'].select{|k,v| k.in?(categorical_trait_indices)}.reject{|k,v| v.empty?}.each do |k,v|
          trait_id = Integer(v)
          trait_category_ids = @categorical_trait_category_map[trait_id] || []

          if params['trait_values'][k]
            unless params['trait_values'][k].blank?
              trait_category_ids << Integer(params['trait_values'][k])
            end
          end
          @categorical_trait_category_map[trait_id] = trait_category_ids
        end
      end
    end
  end

  def taxa_in_iczn_group_with_parents(iczn_group_id, parent_taxon_ids)
    iczn_group = @project.iczn_groups.find(iczn_group_id)
    taxon_ids = @project.taxa.where(:id => parent_taxon_ids).map{|t| t.descendants_with_level(iczn_group).map{|x| x.id}}.inject{|memo,id| memo & id}
    return @project.taxa.where(:id => taxon_ids).sorted
  end

  def traits
    return @project.categorical_traits.sorted
  end

  def categorical_trait_values_for_trait(trait_id)
    if trait_id
      trait = @project.categorical_traits.find(trait_id)
      return trait.categorical_trait_categories
    end
  end
end
