# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
set :stage, :development
set :rails_env, :development
set :unicorn_config_path, "#{shared_path}/production_config/unicorn/#{fetch(:rails_env)}.rb"

role :app, '192.168.33.201'
role :web, '192.168.33.201'
role :varnish, '192.168.33.201'
role :db,  '192.168.33.201', :primary => true

after "deploy:symlink:shared", "deploy:ln_sqlite3_file"
