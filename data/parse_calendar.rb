require 'nokogiri'

def process_cell(list)
  out = []
  current = {}
  list.each do |item|
    if item =~ /(.*)_S2/
      out << current
      current = { :name => $1 }
    elsif item =~ /Room: (.*)/
      current[:location] = $1
    elsif item.gsub(/[\u0080-\u00ff]/, "").strip == ""
      next
    else
      # current[:name] += " " + item
    end
  end

  out << current
  out.drop(1)
end


def get_timetable
  @timetable ||= begin
    doc = File.read("./data/table.html")

    tree = Nokogiri::HTML(doc)

    table = tree.css("center table")

    rows = table.xpath('tbody/tr')

    timetable = []

    example = ["ACST4033_S2", "Lecture A", "(cont)", "Room: CBE Bld LT 4", "ACST8033_S2", "Lecture A", "Room: CBE Bld LT 4"]


    rows.drop(1).each do |x|
      timetable << x.xpath("td").children.drop(2).to_a.map do |cell|
        process_cell(cell.children.to_a.map { |x| x.children.map(&:text) }.flatten.select { |x| x.length > 0 })
      end
    end

    better_timetable = []

    timetable.each_with_index do |hour, index|
      hour.zip([:mon, :tue, :wed, :thu, :fri]).each do |slot, day|
        slot.each do |lesson|
          lesson[:day] = day
          lesson[:hour] = index + 8
          better_timetable << lesson
        end
      end
    end

    better_timetable
  end
end

p get_timetable