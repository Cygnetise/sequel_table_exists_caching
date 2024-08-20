require 'rake/clean'

CLEAN.include %w[**.rbc rdoc coverage]

desc 'Do a full cleaning'
task :distclean do
  CLEAN.include %w[tmp pkg sequel_table_exists_caching*.gem lib/*.so]
  Rake::Task[:clean].invoke
end

desc 'Build the gem'
task :gem do
  sh %(gem build sequel_table_exists_caching.gemspec)
end

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('sequel_table_exists_caching')
rescue LoadError
end
