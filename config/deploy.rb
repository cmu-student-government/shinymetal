lock '3.4.0'
require 'whenever/capistrano'

set :application, 'bridgeapi'
set :repo_url, 'git@github.com:jkcorrea/shinymetal.git'
set :scm, :git
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"

set :password, ask("StuGov server password", "", echo: false)
set :ssh_options, { forward_agent: true }

# Restart passenger the old-school way
set :passenger_restart_with_touch, true

set :whenever_command, 'bundle exec whenever'

# namespace :deploy do
  # desc "Update the crontab file"
  # task :update_crontab do
  #   run "bundle exec whenever --update-crontab #{application}"
  # end

  # task :symlink_php_endpoints do
  #   on roles(:all) do
  #     execute :ln, "-nfs #{shared_path}/public/jira.php #{release_path}/public/jira.php"
  #     execute :ln, "-nfs #{shared_path}/public/api.php #{release_path}/public/api.php"
  #   end
  # end
# end
# before "deploy:assets:precompile", "deploy:symlink_php_endpoints"
# after "deploy:assets:precompile", "whenever:update_crontab" Don't want to overwrite working crontab

# Taken from https://gist.github.com/patte/7684360
namespace :figaro do
  desc "SCP transfer figaro configuration to the shared folder"
  task :transfer do
    on roles(:app) do
      upload! "config/application.yml", "#{shared_path}/application.yml", via: :scp
    end
  end

  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/application.yml #{current_path}/config/application.yml"
    end
  end
end
after "deploy:started", "figaro:transfer"
after "deploy:updating", "figaro:symlink"
