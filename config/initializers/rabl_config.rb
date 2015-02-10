

Rabl.configure do |config|
  config.include_json_root = true
  config.replace_empty_string_values_with_nil_values = true
  config.exclude_nil_values = true
  config.exclude_empty_values_in_collections = true
end

