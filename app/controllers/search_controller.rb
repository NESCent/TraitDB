class SearchController < ApplicationController
  def index
    @taxa = {}
    # Higher taxonomic group
    @taxa[:htg] = htg_taxa
    # Order
    @taxa[:order] = order_taxa
    # Family
    @taxa[:family] = family_taxa_in_order(@taxa[:order].first)
    # Genus
    @taxa[:genus] = genus_taxa_in_family(@taxa[:family].first)
    @trait_groups = []
    @trait_names = CategoricalTrait.sorted
    @trait_values = trait_values_for_trait(@trait_names.first)
  end

  def list_order
    @order_list = order_taxa
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

  def list_traits
    @traits = traits_in_group(params[:trait_group_id])
    render :json => @traits
  end

  def list_trait_values
    @trait_values = trait_values_for_trait(params[:trait_id])
    render :json => @trait_values
  end

  private

  def htg_taxa
    return Taxon.ungrouped_taxa.sorted
  end

  def order_taxa
    return Taxon.order_taxa.sorted
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

  def trait_values_for_trait(trait_id)
    if trait_id
      trait = CategoricalTrait.find(trait_id)
      return trait.categorical_trait_categories
    else
      return []
    end
  end
end
