require 'rake'
require 'rufus-scheduler'

Thorberry::Application.load_tasks

schedule = Rufus::Scheduler.singleton

schedule.interval '5s' do
  Rake::Task['scripts:prophet'].execute
end
