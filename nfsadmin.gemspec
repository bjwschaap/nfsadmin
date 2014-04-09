# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','nfsadmin','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'nfsadmin'
  s.version = Nfsadmin::VERSION
  s.author = 'Bastiaan Schaap'
  s.email = 'b.schaap@siteminds.nl'
  s.homepage = 'https://github.com/bjwschaap/nfsadmin'
  s.platform = Gem::Platform::RUBY
  s.summary = 'This gem contains a library and CLI tool for managing the NFS service and exports'
  s.description = <<eos
                  This gem contains a library and CLI tool for managing the NFS service and exports. It depends on
                  autofs to be installed, and the service NFS to be available. This is my first attempt at a
                  RubyGem, and much still needs to be done. Only tested on Centos 6 at this time.
eos
  s.license = 'MIT'
  s.files = `git ls-files`.split("\n")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','nfsadmin.rdoc']
  s.rdoc_options << '--title' << 'nfsadmin' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'nfsadmin'
  s.required_ruby_version = '~> 2.0'
  s.add_development_dependency('rake', '~> 10.2' )
  s.add_development_dependency('rdoc', '~> 4.1')
  s.add_development_dependency('aruba', '~> 0.5')
  s.add_runtime_dependency('gli','~> 2.9')
end
