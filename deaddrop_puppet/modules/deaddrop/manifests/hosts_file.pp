class deaddrop::hosts_file {
    file { "/etc/hosts":
        ensure => file,
        path => "/etc/hosts",
        content => template("deaddrop/hosts.erb"),
        owner => 'root',
        group => 'root',
        mode => '0644',
    }
}
