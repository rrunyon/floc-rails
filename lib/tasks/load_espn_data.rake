desc "Fetch, parse, and load league data from ESPN"
task :load => :environment do
  Espn::Loader.new.run
end
