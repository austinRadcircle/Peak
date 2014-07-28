# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'radcircle'
set :repo_url, 'git@github.com:radcircle-dev/Peak.git'
set :default_env, { path: "/usr/bin:~/.rbenv/shims:~/.rbenv/bin:$PATH" }
set :rbenv_ruby, '2.1.1'
set :rails_env, 'production'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/rails/apps/radcircle'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

set :unicorn_env, 'production'
set :unicorn_config_path, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/tmp/pids/unicorn.pid"

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc "Precompile assets locally and then rsync to web servers"
  task :compile_assets do
    on roles(:web) do
      rsync_host = host.to_s # this needs to be done outside run_locally in order for host to exist
      run_locally do
        with rails_env: fetch(:stage) do
          execute :bundle, "exec rake assets:precompile"
        end
        execute "rsync -av --delete ./public/assets/ rails@#{rsync_host}:#{shared_path}/public/assets/"
        execute "rm -rf public/assets"
        # execute "rm -rf tmp/cache/assets" # in case you are not seeing changes
      end
    end
  end

  after :updated, "deploy:compile_assets"
  after :publishing, :restart

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
    invoke 'unicorn:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end

