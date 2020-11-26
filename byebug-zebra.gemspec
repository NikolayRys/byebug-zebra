require File.dirname(__FILE__) + '/lib/byebug-zebra/version'

Gem::Specification.new do |spec|
  spec.name          = 'byebug-zebra'
  spec.version       = Byebug::Zebra::VERSION
  spec.authors       = ['Nikolay Rys']
  spec.email         = ['nikolay@rys.me']

  spec.summary       = 'Smart backtrace navigation for Byebug and Pry.'
  spec.description   = 'Makes byebug and pry aware of project directory structure and used libraries, allowing to jump between them.'
  spec.homepage      = 'https://github.com/NikolayRys/byebug-zebra'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # TODO: Put your gem's CHANGELOG.md URL here.
  # spec.metadata['changelog_uri'] = ''

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'

  spec.add_dependency 'byebug', '~> 11.1'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'tty-prompt', '~> 0.22'

  # This dependency is not a requirement, but since we extend pry as well, we need to test it
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
end
