# config/initializers/load_config.rb
if File.exists?(File.join(Rails.root, 'config', 'app_config.yml'))
  APP_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'app_config.yml'))[Rails.env]
  ActionMailer::Base.default_url_options = { :host => APP_CONFIG['host_for_email_links'] }
end