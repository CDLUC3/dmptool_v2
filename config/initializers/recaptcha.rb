C = YAML.load_file(Rails.root.join("config","app_config.yml"))[Rails.env]
Recaptcha.configure do |config|
  config.public_key  = C['recaptcha_public_key']
  config.private_key = C['recaptcha_private_key']
end