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
        # To test "users", comment out the before_filter, and uncomment the next line:
        #@user_key = UserKey.select{|uk| uk.columns.restrict_to("users").size>0}.to_a.first

        # this conditional filters out the rows of the response. if the params
        # POSTed are not a valid combination of filters to use, it will
        # immediately reject the response
        request = EndpointRequest(@user_key, params)
        if request.valid?
          response = EndpointResponse.new(params)
          if response.failed
            render json: {"message" => "error, the requested resource does not exist"}
          end        

          # find the appropriate filter_columns for a given user key
          final_columns = @user_key.columns.restrict_to(request.endpoint).to_a.map{|c| c.name}

          if final_columns.empty?
            render json: ({"message" => "error, no columns permitted for this resource"})
          else
            response.restrict_to_columns(final_columns)
            final_hash = response.to_hash
            render json: JSON(final_hash), status: 200
          end
        else
          render json: {"message" => "error, the combination of parameters used is not valid for this API key"}
        end
      end
      
      private
      #return whether the passed in api_key exists in our system
      def key_matches?(api_key, andrew_id)
        @cur_user = User.find_by_andrew_id(andrew_id)
        if @cur_user
          # Safe because all andrew_ids are guaranteed to be unique
          # Find the user key that belngs to the given API number
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
          render json: {error: "Error, unauthorized user or API key"}, status: 401
        elsif !@cur_user.active
          render json: {error: "Error, the account associated with this andrew ID has been suspended"}, status: 401
        end
      end
    end
  end
end