require "./logger/*"
require "option_parser"

module Logger

  arguments = [] of String
  password = ""
  option_parser = nil

  COMMANDS = <<-CMD

  Available commands:
    list                               List all available log files
  CMD

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
      puts COMMANDS
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
    puts COMMANDS
    exit 1
  end

  # Check if a command was given
  unless arguments.size > 0
    puts "Missing command"
    puts option_parser
    puts COMMANDS
    exit 1
  end

  fetcher = Fetch.new password

  case arguments[0]
  when "list"
    fetcher.list do |list|
      list.each do |item|
        puts "#{item}"
      end
    end
  else
    puts "#{arguments[0]} is not a valid command"
    puts option_parser
    puts COMMANDS
    exit 1
  end
end
