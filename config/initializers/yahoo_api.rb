module YahooApi
  # APP_KEYとAPP_SECRETは本番環境で変更
  APP_KEY ||= 'dj0zaiZpPXd2clRsS3VOaFBFbSZzPWNvbnN1bWVyc2VjcmV0Jng9NDA-'
  APP_SECRET ||= 'f38070e139549e9031af7ec2c30db6320df9d6f3'
  MAP_LIB ||= 'http://js.api.olp.yahooapis.jp/OpenLocalPlatform/V1/jsapi'
  GEO_LIB ||= 'http://geo.search.olp.yahooapis.jp/OpenLocalPlatform/V1/geoCoder'
  KEY ||= 'appid'

  def self.map_lib
    [MAP_LIB, key_param].join '?'
  end

  def self.geo_lib
    GEO_LIB
  end

  def self.key_param
    [KEY, APP_KEY].join '='
  end

  private_class_method :key_param
end
