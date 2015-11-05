server 'stugov.andrew.cmu.edu', user: 'jkcorrea', roles: %w{web app}
set :deploy_to, "/var/www/webapps/#{fetch(:application)}"
set :stage, :production
set :rails_env, :production
set :rvm_type, :system
set :rvm_ruby_version, '2.1.6'
