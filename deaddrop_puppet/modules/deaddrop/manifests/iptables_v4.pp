class deaddrop::iptables_v4 {
    $dependents = [ "iptables" ] 
    package { $dependents: ensure => "installed" }

    file {'/etc/iptables':
        ensure => directory,
        owner => 'root',
        group => 'root',
    }

    file {'/etc/iptables/rules_v4':
        ensure => file,
        content => template("deaddrop/iptables_v4.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
        require => Package[$dependents],
    }
  
    exec { 'iptables-restore < /etc/iptables/rules_v4':
        cwd => '/etc/iptables',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        user => 'root',
        group => 'root',
        subscribe => File['/etc/iptables/rules_v4'],
        refreshonly => true,
    }
}
