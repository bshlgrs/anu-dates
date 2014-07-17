Rails.application.routes.draw do
  get "/", to: "timetables#new"
  post "/anu_s2", to: "timetables#create"
  get "/courses/:course", to: "timetables#course"
end
