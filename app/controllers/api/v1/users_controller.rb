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
        # parse the JSON string from the collegiate link API into a hash
        body = JSON.parse(hit_api_endpoint("users"))
        # once we have entries in user_key_columns, we can say
        # filter_columns = UserKey.find_by_id(find_user_key_id_by_andrew_id(params[:andrew_id])).columns
        # these are temporary columns our API will white list
        filter_columns = ["username", "firstName", "lastName", "campusEmail", "status"]
        result_hash = {"results" => body["items"].map{|result| result.select{ |k, v| filter_columns.include?(k) } } }

        render json: JSON(result_hash), status: 200

      end

      def find_user_key_id_by_andrew_id(andrew_id)
        @cur_user = User.search(andrew_id)[0]
        @user_keys_to_ids = @cur_user.user_keys.active.not_expired.confirmed.map{|uk| {uk.gen_api_key => uk.id} }
        api_key = params[:api_key]
        # map to a list of ids where if the id matches, then return that id else 0
        result = @user_keys_to_ids.map{|d| !d[api_key].nil? ? d[api_key] : 0}
        # the id will then be added to all zeroes and can be returned
        id = result.reduce(:+)
        # in the case where no user_keys are found to match the user and api_key
        final_id = id > 0 ? id : nil
        return final_id
      end
      
      private
      #return whether the passed in api_key exists in our system
      def key_matches?(api_key, andrew_id)
        if User.all.map{|u| u.andrew_id}.include?(andrew_id)
          # safe because we know the andrew_id is in the system, and must be
          # first because all andrew_ids are guaranteed to be unique
          @cur_user = User.search(andrew_id)[0] 
          # need to check all active, non-expired keys associatd with the user
          return @cur_user.user_keys.active.not_expired.map{|uk| uk.gen_api_key}.include?(api_key)
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