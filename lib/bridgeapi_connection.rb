require 'base64'
require 'openssl'
require 'net/http'

# Stores the inter-server logic for hitting an API endpoint with some params.
module BridgeapiConnection
  # Called with request paramaters to get a response from CollegiateLink.
  #
  # @param params [HashWithIndifferentAccess] Parameters passed in representing an API request.
  # @return [String, Hash] Hash of data response if request worked, or a blank string if it didn't.
  # :nocov:
  def hit_api_endpoint(params)
    if (Rails.env.staging? || Rails.env.production?)
      hit_api_direct(params)
    else
      hit_api_local(params)
    end
  end

  private
  def hit_api_direct(params)
    # CollegiateLink API needs some data to be hashed and sent for auth purposes
    time = (Time.now.to_f * 1000).to_i.to_s
    ipaddress = SETTINGS[:cl_ipaddress]
    apikey = SETTINGS[:cl_apikey]
    privatekey = SETTINGS[:cl_privatekey]
    random = SecureRandom.hex
    hash = Digest::SHA256.hexdigest(apikey + ipaddress + time + random + privatekey)

    # Specify which endpoint we'd like to request from. If you want a specific
    #   id from this endpoint, just do <endpoint>/<id>, for example: events/105
    resource = params[:endpoint]
    options = params.reject{ |k,v| k == :endpoint }

    # Any optional parameters that are listed for this endpoint in the API docs
    # can then be constructed into the URL
    url_options = ""
    options.each{ |k, v| url_options << "&#{k.to_s}=#{v}" }

    url = SETTINGS[:cl_apiurl] + resource + "?time=" + time + "&apikey=" + apikey + "&random=" + random + "&hash=" + hash + url_options
    return send_request(url, nil)
  end

  def hit_api_local(params)
    # Set the optional page number to the first page if not otherwise specified
    params[:page] ||= "1"

    # Authentication info, don't share this!
    pass = SETTINGS[:stugov_api_user]
    priv = SETTINGS[:stugov_api_pass]
    # Our base URL hosted on stugov's server
    base_url = SETTINGS[:stugov_api_base_url]

    # We make a sha256 hash of this in binary format, then base64 encode that
    digest = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), priv, pass)).chomp

    # Specify which endpoint we'd like to request from. If you want a specific
    #   id from this endpoint, just do <endpoint>/<id>, for example: events/105
    resource = params[:endpoint]
    options = params.reject{ |k,v| k == :endpoint }

    # Any optional parameters that are listed for this endpoint in the API docs
    # can then be constructed into the URL
    url_options = ""
    options.each do |k, v|
      url_options = url_options + "&#{k.to_s}=#{v}"
    end

    url = base_url + "?resource=" + resource + url_options
    return send_request(url, digest)
  end
  # :nocov:

  def send_request(requrl, digest)
    url = URI.parse(requrl)
    # Create our request object and set the Authentication header with our encrypted data
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Make our request object with Auth field
    req = Net::HTTP::Get.new(url.to_s)
    req.add_field("Authentication", digest) if digest

    # Send the request, put response into res

    # FIRXME handle errors
    res = https.request(req)

    # Return an empty string if res.body is blank
    return "" if res.body.blank?

    # Output successful result
    return JSON.parse(res.body)
  end
end
