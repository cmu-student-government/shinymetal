# use POST via HTTPS
# symlink protected
# double handshake
module Api
  # Holds the first version of the API controller.
  module V1
    # This controller is in a API/v1 folder to allow for
    # for future versions of the API to coexist with this one in the future.
    # Changes are not expected, but this would allow for changes to be more easily
    # made to the API in the future.
    class ApiController < ApplicationController
      # Allow POST request to be made from another application.
      # No CSRF concern, since the post request includes API key credentials.
      skip_before_filter :verify_authenticity_token

      # Validate and fetch the key data before processing the API request.
      before_filter :verify_access_with_api_key

      # Used to process all API requests.
      def index
        # if the endpoint is the demo endpoint for checking credentials,
        # just return a straightforward success response
        if params[:endpoint] == "demo_endpoint"
          render json: {"message" => "Success! You've made an API request with valid credentials!"}
        else
          # If the params POSTed are not a valid combination of filters to use, i
          # the "request" will fail.
          request = EndpointRequest.new(@user_key, params)
          # request.failed is an error message if the filters aren't permitted for this key.
          unless request.failed
            # The 'response' will fail if there are no columns for this key for this
            # resource, or if resource name was invalid.
            response = EndpointResponse.new(@user_key, params)
            unless response.failed
              if (params[:format] == "jsonp")
                render json: JSON(response.to_hash), status: 200, callback: params[:callback]
              else
                render json: JSON(response.to_hash), status: 200
              end
            else
              # response.failed is an error message if something went wrong.
              render json: {"message" => response.failed }
            end
          else
            render json: {"message" => request.failed }
          end
        end
      end

      private
      # Returns whether the passed-in api_key exists in our system,
      # and is confirmed/not expired/active.
      # Also sets @user_key to the key it finds, if it finds one.
      #
      # @param api_key [String] A potential key value.
      # @param andrew_id [String] A potential CMU andrew id.
      # @return [Boolean] True iff a valid ke was found.
      def key_matches?(api_key, andrew_id)
        # This is safe to do, because all andrew_ids are guaranteed to be unique.
        @cur_user = User.find_by_andrew_id(andrew_id)
        if @cur_user
          # Find the user key that belngs to the given API number.
          for key in @cur_user.user_keys.active.not_expired.confirmed
            if key.gen_api_key == api_key
              @user_key = key
              return true
            end
          end
        end
        return false
      end

      # Used in the before_filter callback to verify whether or not
      # the api key and andrew ID passed in.
      def verify_access_with_api_key
        api_key   = request.headers["HTTP_API_KEY"]
        andrew_id = request.headers["HTTP_ANDREW_ID"]
        if (api_key.nil? || andrew_id.nil?)
          render json: {error: "Error, bad request"}, status: 400
        elsif !(key_matches?(api_key, andrew_id))
          render json: {error: "Error, unauthorized user or API key"}, status: 401
        # Inactive users are not allowed to use their keys for any reason.
        elsif !@cur_user.active
          render json: {error: "Error, the account associated with this andrew ID has been suspended"}, status: 401
        end
      end
    end
  end
end
