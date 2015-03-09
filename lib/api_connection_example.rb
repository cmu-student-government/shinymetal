require 'base64'
require 'openssl'
require 'net/http'

# Authentication info, don't share this!
pass = "SH1NY-M3T4L!"
priv = "54ef594bd7298"

# We make a sha256 hash of this in binary format, then base64 encode that
digest = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), priv, pass)).chomp

# Our base URL hosted on stugov's server
base_url = "https://stugov.andrew.cmu.edu/bridgeapi/test.php"

# Specify which endpoint we'd like to request from. If you want a specific
#   id from this endpoint, just do <endpoint>/<id>, for example: events/105
resource = "memberships"

# Any optional parameters that are listed for this endpoint in the API docs
optional_params = "&page=1"
# Now we construct the full url
url = URI.parse("#{base_url}?resource=#{resource}#{optional_params}")

# Create our request object and set the Authentication header with our encrypted data
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE

# Make our request object with Auth field
req = Net::HTTP::Get.new(url.to_s)
req.add_field("Authentication", digest)

# Send the request, put response into res
res = https.request(req)

# Output result
puts res.body
