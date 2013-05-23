class deaddrop::source {
    $my_role    =   'source'
    $ossec_role = 'agent'
    $enable_mods   = 'ssl wsgi'
    $disabled_mods = 'auth_basic authn_file autoindex cgid env setenvif status'

    include rng_tools
    include deaddrop::hosts_file
    include deaddrop::tcp_wrappers
    include apache
    include apache::mod::wsgi
    include deaddrop::source_deaddrop
    include tor::hidden_service
    include deaddrop::sshfs_remote
    include deaddrop::python_gnupg
    include deaddrop::apache_config
    include deaddrop::ossec_agents
#    include deaddrop::apparmor

    a2mod { "$disabled_mods": ensure => 'absent' }

    a2mod { "$enable_mods": ensure => 'present' }

    exec { "a2enmod $enable_mods":
        user => 'root',
        group => 'root',
        logoutput => 'true',
    }

    exec { "a2dismod $disabled_mods":
        user => 'root',
        group => 'root',
        logoutput => 'true',
    }

    apache::vhost { "127.0.0.1":
       vhost_name => "127.0.0.1",
       port => '8080',
       priority => '15',
       docroot => "$deaddrop_home/static",
       options => 'None',
       template => 'deaddrop/vhost-deaddrop.conf.erb',
    }
    
}
