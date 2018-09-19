# rails-api
redish backend api server

## git clone
```
# vagrant ssh前に実行
$ git clone git@github.com:hyper-nomad/rails-api.git
$ cd rails-api
```

## vagrant
```
$ vagrant plugin install vagrant-vbguest
$ vagrant up
$ vagrant ssh
$ sudo yum -y update
$ sudo yum -y install git
$ git clone https://github.com/dotinstallres/centos6.git
$ cd centos6
$ ./run.sh
$ exec $SHELL -l
$ ruby -v
ruby 2.3.1p112
```

## bundler
```
# vagrant ssh後に実行
$ gem install bundler
$ bundle -v
Bundler version 1.16.5
```

# rails-api
```
# vagrant ssh後に実行
# cd /vagrant/
$ bundle install --path vendor/bundle
$ cp config/database.yml.example config/database.yml
$ cp config/accounts.example.yml config/accounts.yml
$ rake db:create db:migrate db:seed
```
以上を順次実行すればdevelopment環境でrails-apiを実行する準備は完了です。

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
