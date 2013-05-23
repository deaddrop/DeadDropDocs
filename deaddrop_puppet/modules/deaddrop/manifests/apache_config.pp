class deaddrop::apache_config {
    file { '/etc/apache2/conf.d/other-vhosts-access-log':
        ensure => 'absent',
    }

    file { '/var/www/index.html':
        ensure => 'absent',
    }

    file { 'ports.conf':
        ensure => file,
        path => '/etc/apache2/ports.conf',
        content => template("deaddrop/ports.conf.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
    }

    file { 'apache2.conf':
        ensure => file,
        path => '/etc/apache2/apache2.conf',
        content => template("deaddrop/apache2.conf.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
    }

    file { 'security':
        ensure => file,
        path => '/etc/apache2/conf.d/security',
        content => template("deaddrop/security.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
    }

}

