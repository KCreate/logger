require "./endpoint.cr"

module Logger

  # Fetches log files from the endpoint
  class Fetch < EndPoint

    # Returns a list of filenames of logfiles
    def list
      response = @client.get("/resources/logs/list")
      list = JSON.parse(response.body)

      # Check if a list value was given
      unless list = list.as_h
        raise Exception.new("Server response was not a JSON object")
      end

      unless list.has_key? "logs"
        raise Exception.new("No list value given in response")
      end

      list = list["logs"]

      unless list.is_a? Array
        raise Exception.new("logs is not an array")
      end

      yield list
    end
  end

end
