# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'

VoteReports::Application.load_tasks

begin
  require 'airbrake'

  def rescue_and_reraise
    yield
  rescue => e
    Airbrake.notify(e)
    raise
  end
rescue LoadError
  puts "airbrake not available"
end

task default: [:spec, :'cucumber:rerun']

task :update do
  Rake::Task["sunlight:politicians:download"].invoke
  Rake::Task["sunlight:politicians:unpack"].invoke

  Rake::Task['gov_track:download_all'].invoke
  Rake::Task['gov_track:politicians:unpack'].invoke  # 18.0m
  Rake::Task['gov_track:committees:unpack'].invoke  #  2.5m
  ENV['MEETING'] = '112'
  Rake::Task["gov_track:bills:unpack"].invoke
  Rake::Task["gov_track:amendments:unpack"].invoke
  Rake::Task["gov_track:votes:unpack"].invoke

  Politician.update_current_office_status!
  Politician.update_titles!
  Rake::Task['politicians:continuous_terms:regenerate'].invoke
end
