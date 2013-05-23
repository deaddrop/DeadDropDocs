class sysstat {
    package { 'sysstat':
        ensure => installed,
    }

    service {"sysstat":
        ensure => running,
        require => Package["sysstat"],
    }

    file {"/etc/default/sysstat":
        ensure => file,
        source => "puppet:///modules/sysstat/etc/default/sysstat",
        owner => 'root',
        group => 'root',
        mode => '0644',
        notify => Service["sysstat"],
        require => Package["sysstat"],
    }
}
 
