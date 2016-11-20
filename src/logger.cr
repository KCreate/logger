require "./logger/*"
require "option_parser"

module Logger

  arguments = [] of String
  password = ""
  option_parser = nil
  dump_start = 0
  dump_end = -1

  COMMANDS = <<-CMD

  Available commands:
    list                               List all available log files
    dump                               Dump the contents of log files to STDOUT
  CMD

  OptionParser.parse! do |opts|
    option_parser = opts

    opts.banner = "Usage: logger [flags]"

    opts.on("-p PASSWORD", "--pass PASSWORD", "Set the password") { |pw|
      password = pw
    }

    opts.on("--dump-start INDEX", "Sets the start index for the dump command") { |ds|
      dump_start = ds.to_i32
    }

    opts.on("--dump-end INDEX", "Sets the end index for the dump command") { |de|
      dump_end = de.to_i32
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
  when "dump"

    fetcher.dump(dump_start..dump_end) do |content|
      puts content
    end
  else
    puts "#{arguments[0]} is not a valid command"
    puts option_parser
    puts COMMANDS
    exit 1
  end
end
