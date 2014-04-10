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
    summarized = nil
    case method
      when :avg
        summarized = all_values.reduce(:+).to_f / all_values.count
      when :first
        summarized = all_values.first
      when :last
        summarized = all_values.last
      when :min
        summarized = all_values.min
      when :max
        summarized = all_values.max
    end
    if merged
      merged[:values] = [{all_keys.first => summarized}]
    end
    return {trait_id => merged}
  end
end
