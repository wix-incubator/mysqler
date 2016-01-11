name              'mysqler'
maintainer        'tata'
maintainer_email  'tata@wix.com'
license           'Apache 2.0'
description       'Installs and configures MySQL client and server'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '1.0.11'

dependencies = %w(
  apt
  openssl
  magic_shell
  percona
  logrotate
  build-essential
)

dependencies.each do |dep|
  depends dep
end

supports 'debian'

replaces 'mysql'
