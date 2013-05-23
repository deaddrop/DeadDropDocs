# Class: secure-delete
#
# This class installs secure-delete
#
# Actions:
#   - Install the secure-delete package
#
# Sample Usage:
#  class { 'secure-delete': }
#
class secure_delete {
  package { 'secure-delete':
    ensure => installed,
  }
}
