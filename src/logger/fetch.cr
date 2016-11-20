require "cossack"
require "json"

module Logger

  # Handles authentication with the endpoint
  abstract class EndPoint
    property authenticated : Bool
    property session_id : String
    property client : Cossack::Client

    FETCH_ENDPOINT = "https://leonardschuetz.ch/"
    FETCH_TYPE_CHECK = "GET"
    FETCH_TYPE_AUTH = "POST"
    FETCH_PASSWORD_FIELD = "password"
    MAX_RETRY_COUNT = 5

    def initialize(password)
      @authenticated = false
      @session_id = ""
      @client = Cossack::Client.new(FETCH_ENDPOINT)
      @client.use Cossack::CookieJarMiddleware, cookie_jar: @client.cookies

      # Try to authenticate to the webservice
      retry_count = 0
      until try_authenticate password
        if retry_count == MAX_RETRY_COUNT
          raise Exception.new("Could not authenticate to #{Fetch::FETCH_ENDPOINT}")
        end

        retry_count += 1
      end
    end

    # Calls the api to check if we are still authenticated
    def authenticated?
      response = @client.get("/auth/status")

      body = JSON.parse(response.body)
      @authenticated = body["authenticated"].as_bool
      @session_id = @client.cookies["SESSID"].value

      @authenticated
    end

    # Tries to authenticate to the webservice via *password*
    def try_authenticate(password)
      auth_body = <<-AUTH
      {
        "password": "#{password}"
      }
      AUTH

      response = @client.post("/auth/status", auth_body) do |request|
        request.headers["Content-Type"] = "application/json"
      end

      body = JSON.parse(response.body)
      @authenticated = body["authenticated"].as_bool
      @session_id = @client.cookies["SESSID"].value

      @authenticated
    end
  end

  # Fetches log files from the endpoint
  class Fetch < EndPoint

    # Returns a list of filenames of logfiles
    def list
      response = @client.get("/resources/log/list")
      puts response

      return [] of String
    end
  end

end
