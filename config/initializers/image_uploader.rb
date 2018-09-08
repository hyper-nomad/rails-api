=begin
require 'carrierwave/orm/activerecord'
S3_CONFIG = YAML.load_file("#{Rails.root}/config/accounts.yml")[Rails.env]["aws"].symbolize_keys!

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: S3_CONFIG[:key],
    aws_secret_access_key: S3_CONFIG[:secret],
    region: S3_CONFIG[:region],
  }

  config.fog_directory = S3_CONFIG[:images_backet]

end

ImageUploader
=end
