# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'bridgeapi'
set :repo_url, 'git@github.com:jkcorrea/shinymetal.git'
set :scm, :git
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"

set :password, ask("StuGov server password", "", echo: false)
set :ssh_options, {
 forward_agent: true,
 auth_methods: %w(password),
 password: fetch(:password)
}


namespace :deploy do

  task :symlink_shared do
    on roles(:all) do
      execute :ln, "-nfs #{shared_path}/config/settings.yml #{release_path}/config/"
    end
  end

  # task :search_reindex do
  #   on roles(:all) do
  #     execute :rake, 'searchkick:reindex:all'
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
# after "deploy",  "deploy:search_reindex"
