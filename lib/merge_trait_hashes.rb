class Array
  # working on continuous for now
  # this will merge the entire hash.
  # TODO: instead just merge the specific trait
  def merge_trait_hashes(trait_id, method=:avg)
    # members of the array will be hashes with
    # {trait_id => {:values => [], :sources => {}, :notes => ??, :value_matches => {}}}
    # Given an array of trait hashes
    traits_matching_id = map{|x| x[trait_id]}.compact
    all_keys = traits_matching_id.map{|x| x[:values]}.flatten.map{|x| x.keys}.flatten
    all_values = traits_matching_id.map{|x| x[:values]}.flatten.map{|x| x.values}.flatten
    merged = select{|x| x[trait_id]}.map{|x| x[trait_id]}.first.deep_dup
    if merged
      case method
        when :avg
          merged[:values] = [{
            all_keys.first => all_values.reduce(:+).to_f / all_values.count
          }]
        when :first
          merged[:values] = [{
            all_keys.first => all_values.first
          }]
        when :last
          merged[:values] = [{
            all_keys.last => all_values.last
          }]
        when :min
          min_value = all_values.min
          i = all_values.index(min_value)
          merged[:values] = [{
            all_keys[i] => min_value
          }]
        when :max
          max_value = all_values.max
          i = all_values.index(max_value)
          merged[:values] = [{
            all_keys[i] => max_value
          }]
        when :collect
          merged[:values] = all_keys.each_with_index.map{|x,i|{ x => all_values[i]}}.uniq
      end
    end
    return {trait_id => merged}
  end
end
