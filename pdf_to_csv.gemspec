# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdf_to_csv/version'

Gem::Specification.new do |spec|
  spec.name          = 'pdf_to_csv'
  spec.version       = PDFToCSV::VERSION
  spec.authors       = ['server.monitor.lizard']
  spec.email         = []

  spec.summary       = 'Download remote PDF file then convert to CSV'
  spec.description   = 'Download remote PDF file then convert to CSV'
  spec.homepage      = ''
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  #   'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing
  #   to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'

  spec.executables   = %w[app]
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.require_paths = ['lib']

  # ...
  %w[httparty paint terminal-table].each { |dep| spec.add_dependency dep }

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
