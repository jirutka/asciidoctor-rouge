source 'https://rubygems.org'
gemspec

unless ENV.fetch('ASCIIDOCTOR_VERSION', '').empty?
  if (match = ENV['ASCIIDOCTOR_VERSION'].match(/^git:(\w+)/))
    gem 'asciidoctor', github: 'asciidoctor/asciidoctor', ref: match[1]
  else
    gem 'asciidoctor', ENV['ASCIIDOCTOR_VERSION']
  end
end

group :ci do
  gem 'codacy-coverage', '~> 1.1', require: false
end
