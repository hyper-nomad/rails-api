# redish-api
redish backend api server

# Ruby install
rubyは2015-05-10現在stable最新バージョンの2.3.1を使っています。
rbenvの利用を想定し、.ruby-versionをgit管理下に置いています。

## bundler
```
$ gem install bundler
$ bundle -v
Bundler version 1.12.3
```

# redish-api
```
$ git clone git@github.com:redish/redish-api.git
$ cd redish-api
$ bundle install --path vendor/bundle
$ cp config/database.yml.example config/database.yml
$ cp config/accounts.example.yml config/accounts.yml
$ rake db:create db:migrate db:seed
```
以上を順次実行すればdevelopment環境でredish-apiを実行する準備は完了です。

## コンソールとサーバの実行
```
$ rails console
$ rails server
```

## rspec実行
```
$ RAILS_ENV=test rake db:drop db:create db:migrate db:seed
$ rspec spec/. -f d
```

## Links
- swagger json
  - http://localhost:3000/api/v2/doc
- swagger ui
  - http://localhost:3000/docs
- sign up
  - http://localhost:3000/users/sign_up

- facebook auth 認証
  - http://localhost:3000/users/auth/facebook
