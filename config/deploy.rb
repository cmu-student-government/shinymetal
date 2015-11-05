# config valid only for Capistrano 3.1
lock '3.4.0'
require 'whenever/capistrano'
set :whenever_command, 'bundle exec whenever'

set :application, 'bridgeapi'
set :repo_url, 'git@github.com:cmu-student-government/shinymetal.git'
set :scm, :git
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"

set :rvm1_ruby_version, '2.1.6'

set :password, ask("StuGov server password", "", echo: false)
set :ssh_options, {
 forward_agent: true,
 auth_methods: %w(password),
 password: fetch(:password)
}

# Load .env files into ENV
set :linked_files, fetch(:linked_files, []).push('.env')

namespace :rvm1 do # https://github.com/rvm/rvm1-capistrano3/issues/45
  desc "Install Bundler"
  task :install_bundler do
    on release_roles :all do
      execute "cd #{release_path} && #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh . gem install bundler"
    end
  end
end
after 'rvm1:install:ruby', 'rvm1:install_bundler'

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

  # task :symlink_php_endpoints do
  #   on roles(:all) do
  #     execute :ln, "-nfs #{shared_path}/public/jira.php #{release_path}/public/jira.php"
  #     execute :ln, "-nfs #{shared_path}/public/api.php #{release_path}/public/api.php"
  #   end
  # end

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
# before "deploy:assets:precompile", "deploy:symlink_php_endpoints"
#after "deploy:assets:precompile", "whenever:update_crontab"
#Don't want to overwrite working crontab
