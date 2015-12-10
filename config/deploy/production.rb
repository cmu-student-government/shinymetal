server 'stugov.andrew.cmu.edu', user: 'jkcorrea', roles: %w{web app}
set :deploy_to, "/var/www/webapps/#{fetch(:application)}"
set :stage, :production
set :rails_env, 'production'
