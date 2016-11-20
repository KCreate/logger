require "terminal_table"

module Logger

  private struct Day
    property name : String
    property views : Hash(Int32, Int32) # hour => views

    def initialize(@name, @views)
    end
  end

  class Analyse
    MONTH_NAMES = {
      "Jan" =>  1,
      "Feb" =>  2,
      "Mar" =>  3,
      "Apr" =>  4,
      "May" =>  5,
      "Jun" =>  6,
      "Jul" =>  7,
      "Aug" =>  8,
      "Sep" =>  9,
      "Oct" => 10,
      "Nov" => 11,
      "Dec" => 12
    }

    WEEK_NAMES = [
      {"Monday", "Mon"},
      {"Tuesday", "Tue"},
      {"Wednesday", "Wed"},
      {"Thursday", "Thu"},
      {"Friday", "Fri"},
      {"Saturday", "Sat"},
      {"Sunday", "Sun"},
    ]

    property days : Array(Day)

    def initialize
      @days = WEEK_NAMES.map do |day|
        Day.new(day[0], {} of Int32 => Int32)
      end
    end

    # Analyze a complete file
    def analyse(file : IO)
      file.each_line do |line|
        parse line
      end
      yield render_result
    end

    # Parse a single log entry
    private def parse(line : String)

      return if line == "\n"

      # Get the different parts of the date entry
      parts = line.split(" ")
      date = parts[3][1..-1]
      date = date.gsub("/", " ").gsub(":", " ").gsub("\n", "").split(" ")

      # Create the Time instance
      date = Time.new(
        date[2].to_i,
        MONTH_NAMES[date[1]],
        date[0].to_i,
        date[3].to_i,
        date[4].to_i,
        date[5].to_i
      )

      # Append the views to the given day and hour
      target = case date
      when .monday?
        @days[0]
      when .tuesday?
        @days[1]
      when .wednesday?
        @days[2]
      when .thursday?
        @days[3]
      when .friday?
        @days[4]
      when .saturday?
        @days[5]
      when .sunday?
        @days[6]
      else
        raise Exception.new("This shouldn't happen...")
      end

      if target.views.has_key? date.hour
        target.views[date.hour] += 1
      else
        target.views[date.hour] = 1
      end
    end

    # Render the data into a nice table
    private def render_result
      table = TerminalTable.new
      table.headings = [
        "Day",
        " 0",
        " 1",
        " 2",
        " 3",
        " 4",
        " 5",
        " 6",
        " 7",
        " 8",
        " 9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16",
        "17",
        "18",
        "19",
        "20",
        "21",
        "22",
        "23"
      ]

      # Insert each day
      @days.each do |day|
        row = [day.name]
        day.views.keys.sort.each do |key|
          row << "#{day.views[key].to_s.rjust(4, ' ')}"
        end
        table << row
      end

      table.render
    end
  end

end
