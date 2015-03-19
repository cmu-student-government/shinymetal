module Api
  module V1
    class UsersController < ApplicationController
      # apparently it's bad to pass in tokens in the URL directly,
      # it can be unsafe. will fix in future
      before_filter :verify_access_with_api_key

      def index
        require "./lib/bridgeapi_connection.rb"
        # modified the script to hit only the specified endpoint
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
      def key_exists?(api_key)
        puts UserKey.all.map{|uk| uk.value}.include?(api_key)
        return UserKey.all.map{|uk| uk.value}.include?(api_key)
      end

      # if there's a key and it exists in our system, it's verified
      def verify_access_with_api_key
        if !(params[:api_key].present? && key_exists?(params[:api_key]))
            render json: {error: "Error, resource not found"}, status: 404
        end
      end

    end
  end
end