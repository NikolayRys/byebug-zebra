lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'byebug-smarttrace/version'

Gem::Specification.new do |spec|
  spec.name          = 'byebug-smarttrace'
  spec.version       = Byebug::Smarttrace::VERSION
  spec.authors       = ['Nikolay Rys']
  spec.email         = ['nikolay@rys.me']

  spec.summary       = 'Adds smart navigation over backtrace to Byebug and Pry.'
  spec.description   = 'Makes byebug aware of project directory structure and used libraries, allowing to jump between them.'
  spec.homepage      = 'https://github.com/NikolayRys/byebug-smarttrace'
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

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  # This dependency is a requirement, but it extends pry too, so we need to test it
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_dependency 'byebug', '~> 11.0'
  spec.add_dependency 'colorize', '~> 0.8'
end
