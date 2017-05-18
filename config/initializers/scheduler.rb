require 'rake'
require 'rufus-scheduler'

Thorberry::Application.load_tasks

schedule = Rufus::Scheduler.singleton

schedule.interval '5s' do
  Rake::Task['scripts:prophet'].execute
  Rake::Task['scripts:executor'].execute
end

schedule.every '1d', first: :now do
  Rake::Task['verman:update'].execute
end
