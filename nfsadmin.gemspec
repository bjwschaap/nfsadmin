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
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','nfsadmin.rdoc']
  s.rdoc_options << '--title' << 'nfsadmin' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'nfsadmin'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
end
