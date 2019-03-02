set :repo_url,        ENV.fetch("CAPISTRANO_REPO",'https://github.com/oasis4hedev/salsa.git')
set :branch,          ENV.fetch("CAPISTRANO_BRANCH", "master")
set :application,     'salsa'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

set :puma_env,        'production'
set :puma_conf,       "#{release_path}/config/puma.rb"
set :puma_bind,       "unix:///tmp/sockets/puma.sock"
set :puma_state,      "/tmp/pids/puma.state"
set :puma_pid,        "/tmp/pids/puma.pid"
set :puma_access_log, "/tmp/log/puma.error.log"
set :puma_error_log,  "/tmp/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord

set :swap_size,       ENV.fetch("SWAP_SIZE", "0").to_f # (only used on swap:create) specify size you want (in GB)
set :swap,            ENV.fetch("SWAP", 'false') # used on enable/disable

set :ssh_options,     { forward_agent: true }

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/config.yml', 'config/secrets.yml', 'config/application.yml', 'config/newrelic.yml', 'public/500.html', 'public/422.html', 'public/404.html')
# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'vendor/bundle', 'zipfiles', 'app/views/instances/custom')
# TODO: see if we needthis in linked_dirs - public/assets/scripts

namespace :puma do
  Rake::Task[:restart].clear_actions

  desc "Overwritten puma:restart task"
  task :restart do
    puts "Overwriting puma:restart to ensure that puma is running. Effectively, we are just starting Puma."
    puts "A solution to this should be found."
    invoke 'puma:stop'
    invoke 'puma:start'
  end

  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir /tmp/sockets -p"
      execute "mkdir /tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      before 'deploy', 'setup'
      invoke 'deploy'
    end
  end

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     invoke 'puma:restart'
  #   end
  # end

  # after  :finishing,    :compile_assets
  # after  :finishing,    :cleanup
  # after  :finishing,    :restart
end

namespace :swap do
  swap = fetch(:swap) != 'false'

  # untested
	# desc 'Create swap'
  # task :create do
  #   on roles(:all) do
  #     info "Creating SWAP space"
  #     execute :sudo, "fallocate -l #{swap}G /swapfile"
  #     execute :sudo, "chmod 600 /swapfile"
  #     execute :sudo, "mkswap /swapfile"
  #     # echo vm.swappiness=0 >> /etc/sysctl.conf
  #     info "SWAP memory successfully created"
  #   end
  # end

  desc 'enable swap'
  task :enable do
    on roles(:all) do
      execute :sudo, "swapon /swapfile"
      info "SWAP memory successfully enabled"
    end
  end
  
  task :disable do
    on roles(:all) do
      execute :sudo, "swapoff /swapfile"
      info "SWAP memory successfully disabled"
		end
  end
  
  # before "setup", "swap:create" if fetch(:swap_size) > 0
  before "deploy", "swap:enable" unless fetch(:swap) == 'false'
  after "deploy", "swap:disable" unless fetch(:swap) == 'false'
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
