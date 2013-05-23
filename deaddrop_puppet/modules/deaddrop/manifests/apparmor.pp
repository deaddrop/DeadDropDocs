class deaddrop::apparmor {
    $dependents = [ "apparmor", "libapache2-mod-apparmor", "apparmor-profiles", "apparmor-utils", "dh-apparmor", "libpam-apparmor", "python-libapparmor", "libapparmor1", "libapparmor-perl"]
 
    package { $dependents: ensure => "installed" }

    file { '/etc/apparmor.d':
      ensure => directory,
      recurse => true,
      path => '/etc/apparmor.d',
      source => "puppet:///modules/deaddrop/${my_role}_apparmor",
      owner => 'root',
      group => 'root',
      mode => '0644',
    }

    a2mod { "apparmor": ensure => 'present'}
    exec { "a2enmod apparmor":
        user => 'root',
        group => 'root',
    }
}
