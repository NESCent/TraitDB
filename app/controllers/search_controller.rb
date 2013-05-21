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
    # Continuous Trait Values
    continuous_trait_predicate_map = {} # Map of continuous_trait_ids to array of value predicates
    if params['continuous_trait_name']
      params['continuous_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
        trait_id = Integer(v)
        trait_predicate = continuous_trait_predicate_map[trait_id] || []

        # Check for the equals/less than/etc
        # get the predicate for this row
        if params['continuous_trait_value_predicates'][k] && params['continuous_trait_entries'][k]
          unless params['continuous_trait_entries'][k].blank?
            field_value = Float(params['continuous_trait_entries'][k])
            case params['continuous_trait_value_predicates'][k]
              when 'gt'
                trait_predicate << ['value > ?', field_value]
              when 'lt'
                trait_predicate << ['value < ?', field_value]
              when 'eq'
                trait_predicate << ['value = ?', field_value]
              when 'ne'
                trait_predicate << ['value != ?', field_value]
            end
          end
        end
        continuous_trait_predicate_map[trait_id] = trait_predicate
      end
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
    # AND or OR
    trait_operator = params['trait_operator'] || OPERATORS[:or]

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
        # for each Otu in the list, see if it has the specified trait values
        continuous_trait_values = []
        matched_trait_otu_count = 0
        continuous_trait_predicate_map.each do |trait_id, predicates_array|
          matched_values = otu.continuous_trait_values.where(:continuous_trait_id => trait_id)
          predicates_array.each do |predicate|
            matched_values = matched_values.where(predicate)
          end
          # If this OTU had a trait value that met the criteria, increment our counter
          unless matched_values.nil? || matched_values.empty?
            # Keep track of how many traits matched to determine if AND was successful
            matched_trait_otu_count += 1
            values = matched_values.map{|continuous_trait_value| continuous_trait_value.value}
            continuous_trait_values << {:continuous_trait_id => trait_id, :values => values }
          end
        end
        row[:continuous_trait_values] = continuous_trait_values # may be an empty array

        categorical_trait_values = []
        total_queried_categorical_values = 0
        categorical_trait_category_map.each do |trait_id, category_ids|
          total_queried_categorical_values += category_ids.count
          matched_values = otu.categorical_trait_values.where(:categorical_trait_id => trait_id).where(:categorical_trait_category_id => category_ids)
          unless matched_values.nil? || matched_values.empty?
            matched_trait_otu_count += matched_values.count
            values = matched_values.map{|categorical_trait_value| categorical_trait_value.categorical_trait_category.name }
            categorical_trait_values << {:categorical_trait_id => trait_id, :values => values }
          end
        end
        row[:categorical_trait_values] = categorical_trait_values # may be an empty array
        # for the case of AND, we must have the same number of results as our input criteria before we add the row to our output set
        if trait_operator == OPERATORS[:and]
          if matched_trait_otu_count == (continuous_trait_predicate_map.length + total_queried_categorical_values)
            rows << row
          end
        else
          # OR, just make sure matched_trait_otu_count > 0
          if matched_trait_otu_count > 0 || params['only_rows_with_data'].nil?
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


  def results2
    # Rows are determined by selected taxa
    # params = {'htg' => {'0' => '21043', '2' => ''}}

    # Collect the IDs of the selected taxa
    otus = []

    params['htg'].reject{|k,v| v.empty?}.each do |k,v|
      # Start with the higher group and narrow if specified
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

      # Find all OTUs with the corresponding level
      otus += Otu.in_taxon(lowest_id, lowest_group)
    end

    # sort the otus
    # Sorting by sort_name takes a long time, leaving this to sort by id!
    otus.sort!

    # Traits - become columns in output

    # If a value is selected for the trait, filter the OTUs to the matching rows
    # But keep in mind that multiple values may be selected here, so we need to collect them all
    categorical_trait_value_map = {}
    if params['categorical_trait_name']
        params['categorical_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
        trait_id = Integer(v)
        trait_category_ids = categorical_trait_value_map[trait_id] || []
        if params['categorical_trait_values'][k]
          unless params['categorical_trait_values'][k].blank?
            trait_category_ids << Integer(params['categorical_trait_values'][k])
          end
        end
        categorical_trait_value_map[trait_id] = trait_category_ids
      end
    end

    categorical_traits = CategoricalTrait.where(:id => categorical_trait_value_map.keys)

    # If only_rows_with_data was checked, remove OTUs that were not coded for the trait
    if (categorical_traits.count > 0) && params['only_rows_with_data']
      otus.reject! {|otu| (otu.categorical_traits & categorical_traits).empty? }
    end

    # Filter out OTUs that were not coded at all if a trait value was chosen
    unless categorical_trait_value_map.values.flatten.empty?
      # trait values were selected, OTUs that don't have them.
      otus.reject! do |otu|
        remove = true
        categorical_trait_value_map.each do |trait_id, trait_value_id|
          leftovers = otu.categorical_trait_categories.map{|c| c.id} - trait_value_id
          if leftovers.size < otu.categorical_trait_categories.size
            # keep this otu since it has a coding that matches the filter
            remove = false
          end
        end
        remove
      end
    end

    # Continuous Trait Values
    continuous_trait_predicate_map = {}
    if params['continuous_trait_name']
      params['continuous_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
        trait_id = Integer(v)
        trait_value_ids = continuous_trait_predicate_map[trait_id] || []

        # Check for the equals/less than/etc
        # get the predicate for this row
        if params['continuous_trait_value_predicates'][k] && params['continuous_trait_entries'][k]
          unless params['continuous_trait_entries'][k].blank?
            field_value = Float(params['continuous_trait_entries'][k])
            case params['continuous_trait_value_predicates'][k]
              when 'gt'
                trait_value_ids << ['value > ?', field_value]
              when 'lt'
                trait_value_ids << ['value < ?', field_value]
              when 'eq'
                trait_value_ids << ['value = ?', field_value]
              when 'ne'
                trait_value_ids << ['value != ?', field_value]
            end
          end
        end
        continuous_trait_predicate_map[trait_id] = trait_value_ids
      end
    end

    # This just gets the headers
    continuous_traits = ContinuousTrait.where(:id => continuous_trait_predicate_map.keys)

    # If only_rows_with_data was checked, remove OTUs that were not coded for the trait
    if (continuous_traits.count > 0) && params['only_rows_with_data']
      otus.reject! {|otu| (otu.continuous_traits & continuous_traits).empty? }
    end

    # Filter out OTUs that were not coded at all if a trait value was chosen
    unless continuous_trait_predicate_map.values.flatten.empty?
      # At least one predicate was chosen, filter out OTUs that don't match
      otus.reject! do |otu|
        remove = true
        matched_values = []
        continuous_trait_predicate_map.each do |trait_id, predicates_array|
          matched_values = otu.continuous_trait_values.where(:continuous_trait_id => trait_id)
          predicates_array.each do |predicate|
            matched_values = matched_values.where(predicate)
          end
        end
        # remove if the otu didn't match any values
        matched_values.empty?
      end
    end

    # data to return to view
    @results = {}
    @results[:include_references] = !params['include_references'].nil?
    @results[:otus] = otus
    @results[:categorical_traits] = categorical_traits
    @results[:continuous_traits] = continuous_traits

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
