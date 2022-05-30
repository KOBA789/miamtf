require_relative "lib/miamtf/version"

Gem::Specification.new do |spec|
  spec.name          = 'miamtf'
  spec.version       = Miamtf::VERSION
  spec.authors       = ['Hidekazu Kobayashi']
  spec.email         = ['kobahide789@gmail.com']
  spec.summary       = 'Miam syntax for Terraform'
  spec.homepage      = 'https://github.com/KOBA789/miamtf'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end
