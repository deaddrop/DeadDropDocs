class deaddrop::remove_pcmcia {
    package { 'pcmcia-cs':
	ensure => absent,
    }

    exec { "K=$(uname -a | awk '{print $3}')":
        cwd => "/root",
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        group => "root",
        user => "root",
       # notify => Exec['aptitude remove kernel-pcmcia-modules-$K'],
    }

    exec { 'aptitude remove kernel-pcmcia-modules-$K':
        cwd => "/root",
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        group => "root",
        user => "root",
       # notify => Exec['aptitude remove pcmcia-modules-$K'],
    }

    exec { 'aptitude remove pcmcia-modules-$K':
        cwd => "/root",
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        group => "root",
        user => "root",
    }

    package { 'hotplug':
	ensure => purged,
    }
}
