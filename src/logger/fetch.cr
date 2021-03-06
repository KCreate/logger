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

      # Check that each value is a string
      values = [] of String
      list.each do |item|
        if item.is_a? String
          values << item
        end
      end

      yield values
    end

    # Yields the contents of all logfiles inside *range*
    def dump(range)
      list do |logs|
        logs[range].each do |log|

          # Request the contents of the file from the server
          response = @client.get("/resources/logs/#{log}")

          if response.headers["Content-Type"] == "application/json"
            raise Exception.new("Got JSON back: #{response.body}")
          else
            yield response.body
          end
        end
      end
    end
  end

end
