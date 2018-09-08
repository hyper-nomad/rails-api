# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
set :stage, :staging
set :rails_env, :staging
set :unicorn_config_path, "#{shared_path}/production_config/unicorn/#{fetch(:rails_env)}.rb"
set :bundle_without, %w{development test}.join(' ')

role :app, %w(sl-sap01 sl-sap02)
#role :db,  'sl-sap01', :primary => true
#role :varnish, %w(sl-svsh01 sl-svsh02)
