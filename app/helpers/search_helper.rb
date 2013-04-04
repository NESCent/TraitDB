module SearchHelper
  def params_for_search(params)
    {:htg => params['htg'],
     :order => params['order'],
     :family => params['family'],
     :genus => params['genus'],
     :categorical_trait_name => params['categorical_trait_name'],
     :categorical_trait_values => params['categorical_trait_values'],
     :only_rows_with_data => params['only_rows_with_data'],
     :continuous_trait_name => params['continuous_trait_name '],
     :continuous_trait_value_predicates => params['continuous_trait_value_predicates'],
     :include_references => params['include_references']
    }
  end
end
