# frozen_string_literal: true

SEQUEL_TABLE_EXISTS_GEMSPEC = Gem::Specification.new do |s|
  s.name = 'sequel_table_exists_caching'
  s.version = '0.1'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.rdoc', 'CHANGELOG', 'MIT-LICENSE']
  s.summary = 'Faster table exists by using caching'
  s.author = 'David Dawson'
  s.email = 'david.dawson@gmail.com'
  s.homepage = 'http://github.com/cygnetise/sequel_table_exists_caching'
  s.required_ruby_version = '>= 2.7'
  s.files = %w[MIT-LICENSE README.rdoc Rakefile lib/sequel/extensions/table_exists_caching.rb]
  s.license = 'MIT'
  s.add_dependency('sequel', ['>= 4.38.0'])
  s.description = <<DESC
  Speeds up using table_exists? information by saving/loading database metadata to a file.
DESC
end
