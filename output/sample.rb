require "rubygems"
require "sinatra"
require "newrelic_rpm"


get "/" do
  redirect("/index.html")
end


get %r{/tags/([^.]+)$} do|tag|
  redirect "/tags/#{tag}.html"
end

get "/tags" do
  redirect "/tags/tags.html"
end
