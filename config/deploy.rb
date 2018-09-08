# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'redish'
set :repo_url, 'https://github.com/redish/redish-api'
set :deploy_to, "/usr/local/rails_apps/#{fetch(:application)}"
set :scm, :git
set :deploy_via, :remote_cache
set :log_level, :debug

set :keep_releases, 5

set :www_user, "www-data"
set :deploy_user, "deploy"

set :use_sudo, false

set :git_shallow_clone, 1
set :keep_releases, 5

set :pty, true
SSHKit.config.umask = '002'

set :rbenv_type, :system # :system or :user
set :rbenv_ruby, '2.1.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, 'app' # default value

# migrate
set :conditionally_migrate, true
set :assets_roles, 'app'           # Defaults to [:web]
#set :assets_prefix, 'prepackaged-assets'   # Defaults to 'assets' this should match con

# bundle
set :bundle_flags, "--quiet"
set :bundle_roles,'app'

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets  public/system public/assets}

netrc_file = ENV['HOME']+'/.netrc'

# User個別設定
user_config = YAML::load(File.read(File.join( File.dirname(__FILE__), "deploy_user_config.yml")))
user_config.each do |k,v|
  set k.to_sym, v
end


namespace :deploy do

  task :update do
    begin
      transaction do
        update_code
        create_symlink
      end
    end
  end

  desc 'upload user netrc files'
  task :upload_netrc do
    on roles(:app) do |host|
      upload!(netrc_file, ".netrc")
    end
  end

  desc 'delete user netrc files'
  task :delete_netrc do 
    on roles(:app) do |host|
      execute "rm -f .netrc"
    end
  end

  task :ln_config_files do
    on roles(:app) do |host|
      {
        "accounts.yml"                  =>  'config',
        "database.yml"                  =>  'config',
        "omniauth.yml"                  =>  'config',
        'devise.rb'                     =>  'config/initializers',
        'asset_sync.yml'		=>  'config',
      }.each do |source, dest|
        execute "ln -nfs #{shared_path}/config/#{source} #{release_path}/#{dest}/#{source}"
      end
      execute "ln -nfs #{shared_path}/config/environments.rb #{release_path}/config/environments/#{fetch(:rails_env)}.rb"
    end
  end

  # for development
  task :ln_sqlite3_file do
    on roles(:db) do |host|
      execute "ln -nfs #{shared_path}/db/development.sqlite3 #{release_path}/db/development.sqlite3"
    end
  end 

  desc 'Restart application'
  task :restart do
    on roles(:app) do |host|
      invoke 'unicorn:restart'
    end
  end

  desc 'Remove git-ssh.sh'
  task :remove_tmp_files do
    on roles(:app) do
      execute "rm /tmp/#{fetch(:application)}/git-ssh.sh"
    end
  end

  # 不要タスクのスキップ
  task :migrate do end
  task :migrations do end

end

namespace :varnish do
  desc 'varnish default'
  task :default do
    invoke "varnish:upload_vcl"
    invoke "varnish:reload_varnish"
  end

  desc 'upload vcl'
  task :upload_vcl do
    on roles(:varnish) do |host|
      execute "mkdir -p -m 775 /tmp/capistrano"
      upload!("config/varnish/#{fetch(:stage)}.vcl", "/tmp/capistrano/default.vcl")
      execute :sudo, "varnishd -d -f /tmp/capistrano/default.vcl -C"
      execute "cp /etc/varnish/default.vcl /tmp/capistrano/default.vcl.#{Date.today}.#{Time.now.to_i}"
      execute :sudo,  "cp /tmp/capistrano/default.vcl /etc/varnish/default.vcl"
      execute "rm /tmp/capistrano/default.vcl"
    end
  end
  desc 'varnish reload'
  task :reload_varnish do
    on roles(:varnish) do |host|
      execute :sudo, "/etc/init.d/varnish reload"
    end
  end
end

namespace :unicorn do

  desc 'restart unicorn'
  task :restart do
    on roles(:app) do |host|
      execute 'sudo /etc/init.d/unicorn reload'
    end
  end

  desc 'start unicorn'
  task :start do
    on roles(:app) do |host|
      execute 'sudo /etc/init.d/unicorn start'
    end
  end

  desc 'unicorn force_reload'
  task :force_reload do
    on roles(:app) do |host|
      execute 'sudo /etc/init.d/unicorn force_reload'
    end
  end

  desc 'unicorn force_restart'
  task :force_restart do
    on roles(:app) do |host|
      execute "sudo /etc/init.d/unicorn force_relstart"
    end
  end

  desc 'unicorn stop'
  task :stop do
    on roles(:app) do |host|
      execute 'sudo /etc/init.d/unicorn stop'
    end
  end

  task :config_upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config/unicorn ]"
        execute "mkdir -p #{shared_path}/config/unicorn"
      end
      upload!("config/unicorn_#{fetch(:rails_env)}.rb","#{shared_path}/config/unicorn/#{fetch(:rails_env)}.rb")
    end
  end
end

before "deploy", "deploy:upload_netrc"
before 'deploy:finished', 'remove_tmp_files'
after "deploy", "deploy:delete_netrc"
after "deploy:symlink:shared", "deploy:ln_config_files"
after 'deploy:publishing', 'deploy:restart'
after 'deploy:assets:precompile', 'deploy:assets:sync'
