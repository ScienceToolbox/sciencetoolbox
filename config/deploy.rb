require "capistrano-rbenv"

set :application, "st"
set :scm, :git
set :repository,  "git@github.com:jure/sciencetoolbox.git"
set :branch, "master"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }
set :rbenv_ruby_version, "ruby-2.0.0-p247"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "178.79.147.250"                          # Your HTTP server, Apache/etc
role :app, "178.79.147.250"                          # This may be the same as your `Web` server
role :db,  "178.79.147.250", :primary => true # This is where Rails migrations will run
role :db,  "178.79.147.250"

set :unicorn_pid, '/tmp/unicorn.st.pid'

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH",
}

set :rails_env, 'production'
set :rack_env, 'production'
set :app_env, 'production'
set :unicorn_env, 'production'

set :user, 'deploy'
set :deploy_to,   "/home/#{user}/apps/#{application}/"
set :current_path, File.join(deploy_to, current_dir)

namespace :db do
  task :db_config, :except => { :no_release => true }, :role => :app do
    run "cp -f #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
after "deploy:finalize_update", "db:db_config"

after 'deploy:restart', 'unicorn:restart'

require "bundler/capistrano"
require "capistrano-unicorn"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
