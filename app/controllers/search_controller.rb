class SearchController < ApplicationController
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
    # Rows are determined by selected taxa
    # params = {'htg' => {'0' => '21043', '2' => ''}}

    # Collect the IDs of the selected taxa
    taxa_ids = []

    params['htg'].reject{|k,v| v.empty?}.each do |k,v|
      # Start with the higher group and narrow if specified
      lowest_id =  Integer(v)
      if params['order'] && params['order'][k]
        lowest_id = Integer(params['order'][k]) unless params['order'][k].blank?
      end
      if params['family'] && params['family'][k]
        lowest_id = Integer(params['family'][k]) unless params['family'][k].blank?
      end
      if params['genus'] && params['genus'][k]
        lowest_id = Integer(params['genus'][k]) unless params['genus'][k].blank?
      end
      taxa_ids << lowest_id
    end

    # Now get all the children OTUs from the taxa IDs
    @otus = []
    taxa_ids.each do |taxa_id|
      @otus += Taxon.find(taxa_id).descendant_otus
    end

    # Categorical traits are selected.
    # These become columns in the output
    trait_category_ids = []

    # If a value is selected for the trait, filter the OTUs to the matching rows
    # But keep in mind that multiple values may be selected here, so we need to collect them all
    @categorical_trait_value_map = {}
    params['categorical_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
      trait_id = Integer(v)
      trait_category_ids = @categorical_trait_value_map[trait_id] || []
      if params['categorical_trait_values'][k]
        unless params['categorical_trait_values'][k].blank?
          trait_category_ids << Integer(params['categorical_trait_values'][k])
        end
      end
      @categorical_trait_value_map[trait_id] = trait_category_ids
    end

    @categorical_traits = CategoricalTrait.where(:id => @categorical_trait_value_map.keys)

    # Filter out OTUs that were not coded at all if a trait value was chosen
    unless @categorical_trait_value_map.values.flatten.empty?
      # trait values were selected, OTUs that don't have them.
      @otus.reject! do |otu|
        remove = true
        @categorical_trait_value_map.each do |trait_id, trait_value_id|
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
    @continuous_trait_predicate_map = {}
    params['continuous_trait_name'].reject{|k,v| v.empty?}.each do |k,v|
      trait_id = Integer(v)
      trait_value_ids = @continuous_trait_predicate_map[trait_id] || []

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
      @continuous_trait_predicate_map[trait_id] = trait_value_ids
    end

    # This just gets the headers
    @continuous_traits = ContinuousTrait.where(:id => @continuous_trait_predicate_map.keys)

    # Filter out OTUs that were not coded at all if a trait value was chosen
    unless @continuous_trait_predicate_map.values.flatten.empty?
      # At least one predicate was chosen, filter out OTUs that don't match
      @otus.reject! do |otu|
        remove = true
        matched_values = []
        @continuous_trait_predicate_map.each do |trait_id, predicates_array|
          matched_values = otu.continuous_trait_values.where(:continuous_trait_id => trait_id)
          predicates_array.each do |predicate|
            matched_values = matched_values.where(predicate)
          end
        end
        # remove if the otu didn't match any values
        matched_values.empty?
      end
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
