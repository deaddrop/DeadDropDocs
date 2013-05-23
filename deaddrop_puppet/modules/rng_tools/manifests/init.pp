# Class: rng-tools
#
# This class installs rng-tools
#
# Actions:
#   - Install the rng-tools package
#
# Sample Usage:
#  class { 'rng-tools': }
#
class rng_tools {
  package { 'rng-tools':
    ensure => installed,
  }

  service { "rng-tools":
    ensure => "running",
    enable => "true",
    require => Package["rng-tools"],
    hasrestart => "true",
    subscribe => File['/etc/default/rng-tools'],
  }

  file { "/etc/default/rng-tools":
    mode => 644,
    owner => 'root',
    group => 'root',
    require => Package["rng-tools"],
    source => "puppet:///modules/rng_tools/rng-tools",
    }
}
