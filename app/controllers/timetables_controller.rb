class TimetablesController < ApplicationController
  def whole_timetable
    require Rails.root.to_s + "/data/parse_calendar.rb"
    @timetable ||= get_timetable
  end

  def new
    render :new
  end

  def course
    render :json => whole_timetable.select { |x| params[:course].upcase == x[:name]}
  end

  def create
    calendar = Icalendar::Calendar.new

    courses = params[:things].upcase.split(",")

    my_lessons = whole_timetable.select { |x| courses.include?(x[:name])}

    days = [:mon, :tue, :wed, :thu, :fri]

    my_lessons.each do |lesson|
      date = DateTime.new(2014, 7, 21) + days.index(lesson[:day]).days + lesson[:hour].hours

      while date < DateTime.new(2014, 10, 31)
        if date < DateTime.new(2014, 9, 7) || date > DateTime.new(2014, 9, 18)
          calendar.event do |e|
            e.summary = lesson[:name]
            e.description = lesson[:info]
            e.dtstart = date.strftime("%Y%m%dT%H%M%S")
            e.dtend = (date + 1.hours).strftime("%Y%m%dT%H%M%S")
            e.location = lesson[:location]
          end
        end

        date += 1.weeks
      end
    end

    respond_to do |wants|
      wants.ics do
        puts calendar
        render :text => calendar.to_ical
      end
      wants.html do
        render :text => "go fuck yourself"
      end
    end
  end
end
