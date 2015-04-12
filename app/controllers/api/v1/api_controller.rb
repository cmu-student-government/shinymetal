# use POST via HTTPS
# symlink protected
# double handshake
module Api
  module V1
    class ApiController < ApplicationController
      skip_before_filter :verify_authenticity_token
      # apparently it's bad to pass in tokens in the URL directly,
      # it can be unsafe. will fix in future
      before_filter :verify_access_with_api_key

      def index
        # FIXME need to modify to consider related filters and build 
        # appropriate query to hit the collegiate link api
        # require "./lib/bridgeapi_connection.rb"
        
        # Note to Ben, if you want to test "users" easily,
        # comment out the before_filter, and uncomment the next line (which gets a key with at least 1 column for users):
        #@user_key = UserKey.select{|uk| uk.columns.restrict_to("users").size>0}.to_a.first
        
        endpoint = params[:endpoint]
        response = EndpointResponse.new(endpoint)
        if response.failed
          render json: {"message" => "error, the requested resource does not exist"}
          return
        end

        # find the appropriate filter_columns for a given user key
        final_columns = @user_key.columns.restrict_to(endpoint).to_a.map{|c| c.name}

        if final_columns.empty?
          render json: {"message" => "error, no columns permitted for this resource"}
        else
          #result_hash = {"results" => body["items"].map{|result| result.select{ |k, v| final_columns.include?(k) } } }
          response.restrict_to_columns(final_columns)
          #final_hash  = request_info_hash.merge(result_hash)
          final_hash = response.to_hash
          render json: JSON(final_hash), status: 200
        end

      end

      def find_user_key_id_by_andrew_id(andrew_id)
        @cur_user         = User.search(andrew_id)[0]
        @user_keys_to_ids = @cur_user.user_keys.active.not_expired.confirmed.map{|uk| {uk.gen_api_key => uk.id} }
        # guaranteed to be non-nil because only called in index controller
        # after verify_access_with_api_key
        puts @user_keys_to_ids
        api_key = request.headers["HTTP_API_KEY"]
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
          #return @cur_user.user_keys.active.not_expired.confirmed.map{|uk| uk.gen_api_key}.include?(api_key)
          for key in @cur_user.user_keys.active.not_expired.confirmed
            if key.gen_api_key == api_key
              @user_key = key
              return true
            end
          end
          
        end
        return false
      end

      # if there's a key and it exists in our system, it's verified
      def verify_access_with_api_key
        api_key   = request.headers["HTTP_API_KEY"]
        andrew_id = request.headers["HTTP_ANDREW_ID"]
        if (api_key.nil? || andrew_id.nil?)
          render json: {error: "Error, bad request"}, status: 400
        elsif !(key_matches?(api_key, andrew_id))
          render json: {error: "Error, unauthorized"}, status: 401
        end
      end

    end
  end
end