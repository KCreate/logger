require "./logger/*"
require "yaml"
require "option_parser"

module Logger

  arguments = [] of String
  password = ""
  option_parser = nil

  OptionParser.parse! do |opts|
    option_parser = opts

    opts.banner = "Usage: logger [flags]"

    opts.on("-p PASSWORD", "--pass PASSWORD", "Set the password") { |pw|
      password = pw
    }

    opts.on("-v", "--version", "Prints the version number") {
      puts "0.1.0"
      exit
    }

    opts.on("-h", "--help", "Print this help message") {
      puts opts
      exit
    }

    opts.unknown_args do |args|
      arguments = args.to_a
    end
  end

  # Check if a password was given
  if password == ""
    puts "Missing password"
    puts option_parser
    exit 1
  end

  fetcher = Fetch.new password

  # Log
  puts "Connected to #{Fetch::FETCH_ENDPOINT}"
end
