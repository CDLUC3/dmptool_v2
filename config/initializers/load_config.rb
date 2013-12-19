# config/initializers/load_config.rb
if File.exists?(File.join(Rails.root, 'config', 'app_config.yml'))
  APP_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'app_config.yml'))[Rails.env]
end