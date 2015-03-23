# use POST via HTTPS
# symlink protected
# double handshake
module Api
  module V1
    class UsersController < ApplicationController
      # apparently it's bad to pass in tokens in the URL directly,
      # it can be unsafe. will fix in future
      before_filter :verify_access_with_api_key

      def index
        # FIXME need to modify to consider related filters and build 
        # appropriate query to hit the collegiate link api
        require "./lib/bridgeapi_connection.rb"
        # modified the script to hit only the specified endpoint
        # FIXME this script doesn't work as of march 23? check later
        render json: hit_api_endpoint("users"), status: 200

        # basic code I had here to figure out how to build a response
        # using Jbuilder. This code responds with all of the users in our
        # shinymetal application, I will then comment this out and add in the
        # other api script
        # @users = User.all
        # if !@users.nil?
        #   @users = User.all
        #   respond_to do |format|
        #     format.json {render json: @users, status: 200}
        #   end
        # else
        #   render json: {message: 'Resource not found'}, status: 404
        # end
      end
      
      private
      #return whether the passed in api_key exists in our system
      def key_matches?(api_key, andrew_id)
        if User.all.map{|u| u.andrew_id}.include?(andrew_id)
          # safe because we know the andrew_id is in the system, and must be
          # first because all andrew_ids are guaranteed to be unique
          @cur_user = User.search(andrew_id)[0] 
          return @cur_user.user_keys.map{|uk| uk.gen_api_key}.include?(api_key)
        end
        return false
      end

      # if there's a key and it exists in our system, it's verified
      def verify_access_with_api_key
        if !(params[:api_key].present? && params[:andrew_id].present?)
          render json: {error: "Error, bad request"}, status: 400
        elsif !(key_matches?(params[:api_key], params[:andrew_id]))
          render json: {error: "Error, unauthorized"}, status: 401
        end
      end

    end
  end
end