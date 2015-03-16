module Api
  module V1
    class UsersController < ApplicationController

      def index
        require "./lib/bridgeapi_connection.rb"
        res = hit_api_endpoint("users")
        # not really sure what to do in the case of
        # 404 status or some other error
        # render json: {message: 'resource not found'}
        render json: res, status: 200

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

    end
  end
end