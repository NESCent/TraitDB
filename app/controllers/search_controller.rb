class SearchController < ApplicationController
  OPERATORS = { :or => 'or', :and => 'and' }
  def index
    @taxa = {}
    # Higher taxonomic group
    @taxa[:htg] = htg_taxa
    # Order
    @taxa[:order] = order_taxa_in_htg(@taxa[:htg].first)
    # Family
    @taxa[:family] = family_taxa_in_order(@taxa[:order].first)
    # Genus
    @taxa[:genus] = genus_taxa_in_family(@taxa[:family].first)
    @trait_groups = []
    @trait_types = [['Categorical', :categorical], ['Continuous', :continuous]]
    @trait_names = {:categorical => CategoricalTrait.sorted, :continuous => ContinuousTrait.sorted }
    @categorical_trait_values = categorical_trait_values_for_trait(@trait_names[:categorical].first)
  end

  def list_htg
    @higher_group_list = htg_taxa
    render :json => @higher_group_list
  end

  def list_order
    @order_list = order_taxa_in_htg(params[:htg_id])
    render :json => @order_list
  end

  def list_family
    @family_list = family_taxa_in_order(params[:order_id])
    render :json => @family_list
  end

  def list_genus
    @genus_list = genus_taxa_in_family(params[:family_id])
    render :json => @genus_list
  end

  def list_trait_groups
    @trait_groups = trait_groups
    render :json => @trait_groups
  end

  #        url: "/search/list_trait_names.json",
#  data: { trait_type_name: traitTypeId}
  def list_categorical_trait_names
    @categorical_trait_names = CategoricalTrait.sorted
    render :json => @categorical_trait_names
  end

  def list_continuous_trait_names
    @continuous_trait_names = ContinuousTrait.sorted
    render :json => @continuous_trait_names
  end

  def list_categorical_trait_values
    @trait_values = categorical_trait_values_for_trait(params[:trait_id])
    render :json => @trait_values
  end

  def results
    trait_operator = params['trait_operator']
    # trait_operator must be 'and' or 'or'.
    # This string is used in database queries and defaults to 'or'
    unless OPERATORS.values.include? trait_operator
      trait_operator = OPERATORS[:or]
    end

    continuous_trait_filters = {}

    # Continuous Trait Values
    if params['continuous_trait_name']
      params['continuous_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
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
        if params['continuous_trait_value_predicates'][k] && params['continuous_trait_entries'][k]
          unless params['continuous_trait_entries'][k].blank?
            field_value = Float(params['continuous_trait_entries'][k])
            case params['continuous_trait_value_predicates'][k]
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
    continuous_trait_predicate_map = {}
    continuous_trait_filters.each do |trait_id, filter|
      continuous_trait_predicate_map[trait_id] = [filter[:predicates].join(" #{trait_operator} "), *filter[:values]]
    end

    headers = {}
    # This just gets the headers
    headers[:continuous_traits] = ContinuousTrait.where(:id => continuous_trait_predicate_map.keys).map do |continuous_trait|
      {:id => continuous_trait.id, :name => continuous_trait.name}
    end

    # Categorical Trait Values
    categorical_trait_category_map = {} # Map of categorical_trait_ids to arrays of categorical_trait_category_ids
    if params['categorical_trait_name']
      params['categorical_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
        trait_id = Integer(v)
        trait_category_ids = categorical_trait_category_map[trait_id] || []

        if params['categorical_trait_values'][k]
          unless params['categorical_trait_values'][k].blank?
            trait_category_ids << Integer(params['categorical_trait_values'][k])
          end
        end
        categorical_trait_category_map[trait_id] = trait_category_ids
      end
    end

    headers[:categorical_traits] = CategoricalTrait.where(:id => categorical_trait_category_map.keys).map do |categorical_trait|
      {:id => categorical_trait.id, :name => categorical_trait.name}
    end

    rows = []

    params['htg'].reject{|k,v| v.empty?}.each do |k,v|
      # Extract the taxon_id from each Taxonomy dropdown
      lowest_id =  Integer(v)
      lowest_group = 'htg'
      if params['order'] && params['order'][k]
        unless params['order'][k].blank?
          lowest_id = Integer(params['order'][k])
          lowest_group = 'order'
        end
      end
      if params['family'] && params['family'][k]
        unless params['family'][k].blank?
          lowest_id = Integer(params['family'][k])
          lowest_group = 'family'
        end
      end
      if params['genus'] && params['genus'][k]
        unless params['genus'][k].blank?
          lowest_id = Integer(params['genus'][k])
          lowest_group = 'genus'
        end
      end

      # Assemble a set of Otus for this selected row
      Otu.in_taxon(lowest_id, lowest_group).each do |otu|
        # Start with a hash containing the OTU
        # This row will only be included in the output set if the criteria is met
        row = { :otu => otu, :sort_name => otu.name }
        match_map = {:continuous => [], :categorical => []}
        # for each Otu in the list, see if it has the specified trait values
        continuous_trait_values = []
        continuous_trait_predicate_map.each do |trait_id, predicate_array|
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
            continuous_trait_values << {:continuous_trait_id => trait_id, :values => values, :sources => sources, :notes => notes}
          end
          # requested count is 1 because predicates for continuous are either met or not met
          match_map[:continuous] << {:trait_id => trait_id, :coded_count => coded_count,
                                     :requested_count => 1,
                                     :matched_count => matched_count}
        end
        row[:continuous_trait_values] = continuous_trait_values # may be an empty array

        categorical_trait_values = []
        categorical_trait_category_map.each do |trait_id, category_ids|
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

        if trait_operator == OPERATORS[:and]
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
      end
    end
    rows.sort! {|a,b| a[:sort_name] <=> b[:sort_name]}

    # data to return to view
    @results = {:headers => headers, # headers is a hash with keys :categorical_traits and :continuous_traits
                :rows => rows, # rows is an array of hashes.  Each hash has :otu, :categorical_trait_values, and :continuous_trait_values
                :include_references => !params['include_references'].nil? }

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

  private

  def htg_taxa
    return Taxon.ungrouped_taxa.sorted
  end

  def order_taxa_in_htg(htg_id)
    if htg_id
      return Taxon.find(htg_id).children.order_taxa.sorted
    else
      return Taxon.order_taxa.sorted
    end
  end

  def family_taxa_in_order(order_id)
    if order_id
      return Taxon.find(order_id).children.family_taxa.sorted
    else
      return Taxon.family_taxa.sorted
    end
  end

  def genus_taxa_in_family(family_id)
    if family_id
      return Taxon.find(family_id).children.genus_taxa.sorted
    else
      return Taxon.genus_taxa.sorted
    end
  end

  def traits
    return CategoricalTrait.sorted
  end

  def categorical_trait_values_for_trait(trait_id)
    if trait_id
      trait = CategoricalTrait.find(trait_id)
      return trait.categorical_trait_categories
    end
  end
end
