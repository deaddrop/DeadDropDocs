class deaddrop::ssh {
    file { "ssh_config":
        ensure => file,
        path => "/etc/ssh/ssh_config",
        source => "puppet:///modules/deaddrop/ssh_config",
        owner => 'root',
        group => 'root',
        mode => '0644',
    }

    file { "sshd_config":
        ensure => file,
        path => "/etc/ssh/sshd_config",
        content => template("deaddrop/sshd_config.erb"),
        owner => 'root',
        group => 'root',
        mode => '0600',
    }

    file { "common-auth":
        ensure => file,
        path => "/etc/pam.d/common-auth",
        source => "puppet:///modules/deaddrop/common-auth",
        owner => 'root',
        group => 'root',
        mode => '0644',
    }
}

