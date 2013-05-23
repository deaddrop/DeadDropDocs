# Class: gnupg2
#
# This class installs gnupg2
#
# Actions:
#   - Install the gnupg2 package
#
# Sample Usage:
#  class { 'gnupg2': }
#
class gnupg2 {
  package { 'gnupg2':
    ensure => installed,
  }
}
