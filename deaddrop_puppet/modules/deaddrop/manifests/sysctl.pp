class deaddrop::sysctl {
    file { "sysctl.conf":
        ensure => present,
        path => '/etc/sysctl.conf',
        source => "puppet:///modules/deaddrop/sysctl.conf",
        owner => 'root',
        group => 'root',
        mode => '0600',
    }

    exec { "sysctl -p":
	cwd => "/etc/",
        group => 'root',
        user => 'root',
        subscribe => File["sysctl.conf"],
        refreshonly => true,
    }
}
