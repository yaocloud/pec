require "bundler/gem_tasks"
require "rspec/core/rake_task"
ENV['CODECLIMATE_REPO_TOKEN'] = "c969d1896316cbd26ab70d3b7fef4f4e168df83b849fa7f16a1885569c86f29c"
ENV['PEC_TEST'] = "test"
RSpec::Core::RakeTask.new("spec")
task :default => :spec
