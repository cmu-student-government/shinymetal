server 'stugov.andrew.cmu.edu', user: 'mvella', roles: %w{web app}
set :deploy_to, "/var/www/staging/webapps/#{fetch(:application)}"
set :stage, :staging
set :rails_env, :staging
set :branch, :dev
