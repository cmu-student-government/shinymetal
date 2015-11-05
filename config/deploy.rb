lock '3.4.0'
require 'whenever/capistrano'
set :whenever_command, 'bundle exec whenever'

set :application, 'bridgeapi'
set :repo_url, 'git@github.com:cmu-student-government/shinymetal.git'
set :scm, :git
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"

set :default_environment, {
  'PATH' => '$PATH:/home/jkcorrea/.rvm/gems/ruby-2.1.6/bin:/home/jkcorrea/.rvm/gems/ruby-2.1.6@global/bin:/usr/local/rvm/rubies/ruby-2.1.6/bin:/usr/local/rvm/bin:/home/jkcorrea/.rvm/gems/ruby-1.9.3-p551/bin:/home/jkcorrea/.rvm/gems/ruby-1.9.3-p551@global/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/jkcorrea/.rvm/bin:/home/jkcorrea/bin'
  'RUBY_VERSION' => 'ruby 2.1.6',
  'GEM_HOME'     => '/home/jkcorrea/.rvm/gems/ruby-2.1.6',
  'GEM_PATH'     => '/home/jkcorrea/.rvm/gems/ruby-2.1.6:/home/jkcorrea/.rvm/gems/ruby-2.1.6@global',
  'BUNDLE_PATH'  => '/home/jkcorrea/.rvm/gems/ruby-2.1.6'  # If you are using bundler.
}

set :password, ask("StuGov server password", "", echo: false)
set :ssh_options, {
 forward_agent: true,
 auth_methods: %w(password),
 password: fetch(:password)
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
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end

before "deploy:assets:precompile", "deploy:symlink_shared"
# before "deploy:assets:precompile", "deploy:symlink_php_endpoints"
#after "deploy:assets:precompile", "whenever:update_crontab"
#Don't want to overwrite working crontab
