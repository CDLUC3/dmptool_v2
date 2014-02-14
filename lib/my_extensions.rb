class Hash
  #Pass an array of keys and this returns the hash with only those keys.
  #Any keys that don't exist in the array are returned with a nil value
  def selected_items(array_keys)
    array_keys.inject({}){|result, key| result[key] = self[key];result}
  end
end