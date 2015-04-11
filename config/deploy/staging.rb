server 'stugov.andrew.cmu.edu', user: 'jkcorrea', roles: %w{web app}
set :deploy_to, "/var/www/staging/webapps/#{fetch(:application)}"
set :stage, :staging
set :rails_env, :staging

