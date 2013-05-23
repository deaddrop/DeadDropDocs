class deaddrop::tcp_wrappers {
    file { '/etc/hosts.allow':
        ensure => file,
	path => '/etc/hosts.allow',
        content => template("deaddrop/hosts.allow.erb"),
        owner => 'root',
	group => 'root',
        mode => '0644',
    }

    file { '/etc/hosts.deny':
        ensure => file,
        path => '/etc/hosts.deny',
        content => template("deaddrop/hosts.deny.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
     }
}

