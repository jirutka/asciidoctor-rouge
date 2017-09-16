require File.expand_path('../lib/asciidoctor/rouge/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'asciidoctor-rouge'
  s.version     = Asciidoctor::Rouge::VERSION
  s.author      = 'Jakub Jirutka'
  s.email       = 'jakub@jirutka.cz'
  s.homepage    = 'https://github.com/jirutka/asciidoctor-rouge'
  s.license     = 'MIT'

  s.summary     = 'Rouge code highlighter support for Asciidoctor'

  s.files       = Dir['lib/**/*', '*.gemspec', 'LICENSE*', 'README*']
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }
  s.has_rdoc    = 'yard'

  s.required_ruby_version = '>= 2.1'

  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'simplecov', '~> 0.14'
  s.add_development_dependency 'yard', '~> 0.9'
end
