desc "Fetch, parse, and upsert league data from ESPN"
task :fetch_espn_data => :environment do
  parser = Espn::Parser.new
  parser.run
end
