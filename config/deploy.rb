# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'bridgeapi'
set :repo_url, 'git@github.com:jkcorrea/shinymetal.git'
set :scm, :git
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"

# set :password, ask("StuGov server password", "", echo: false)
set :ssh_options, {
 forward_agent: true
 # auth_methods: %w(password),
 # password: fetch(:password)
}

# Load .env files into ENV
set :linked_files, fetch(:linked_files, []).push('.env')

namespace :deploy do

  task :symlink_shared do
    on roles(:all) do
      execute :ln, "-nfs #{shared_path}/config/settings.yml #{release_path}/config/"
    end
  end

  desc "Update the crontab file"
  task :update_crontab do
    run "bundle exec whenever --update-crontab #{application}"
  end

  # task :search_reindex do
  #   on roles(:all) do
  #     execute :rake, 'searchkick:reindex:all'
  #   end
  # end

  before "deploy:restart", :symlink_php_endpoints
  task :symlink_php_endpoints do
    run "ln -nfs #{shared_path}/jira.php #{release_path}/public/jira.php"
    run "ln -nfs #{shared_path}/api.php #{release_path}/public/api.php"
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
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

end

before "deploy:assets:precompile", "deploy:symlink_shared"
# after "deploy",  "deploy:search_reindex"
