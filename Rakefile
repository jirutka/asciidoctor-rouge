require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :test => :spec
  task :default => :spec
rescue LoadError => e
  warn "#{e.path} is not available"
end

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names', '--fail-level', 'W']
  end

  task :default => :rubocop
rescue LoadError => e
  warn "#{e.path} is not available"
end
