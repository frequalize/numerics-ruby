# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib', __FILE__)
require 'numerics'

Gem::Specification.new do |s|
  s.name = 'numerics'
  s.version = Numerics::VERSION

  s.authors = ['Ben Lund']
  s.date = "2011-11-19"
  s.summary = 'Official Ruby client for the Numerics.io API'
  s.description = 'Official Ruby client for the Numerics.io API. Numerics.io is a custom metrics and analytics service currently in private alpha.'
  s.email = 'code@numerics.io'
  s.homepage = 'http://github.com/frequalize/numerics-ruby'

  s.add_dependency('yajl-ruby')
  s.files = ['lib/numerics.rb', 'lib/numerics/connection.rb']
end
