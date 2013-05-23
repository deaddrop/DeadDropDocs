class deaddrop::journalist {
    $my_role   		= 'journalist'
    $ossec_role = 'agent'
    $enable_mods        = 'ssl wsgi'
    $disabled_mods = 'auth_basic authn_file autoindex cgid env setenvif status'

    include git
    include rng_tools
    include deaddrop::hosts_file
    include deaddrop::tcp_wrappers
    include apache
    include apache::ssl
    include apache::mod::wsgi
    include deaddrop::sshfs
    include deaddrop::python_gnupg
    include deaddrop::apache_config
    include deaddrop::ossec_agents
#    include deaddrop::apparmor

    a2mod { "$disabled_mods": ensure => 'absent' }
# Having and issue with puppetlabs a2mod define not working
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

    file {"/var/www":
        ensure => directory,
        owner => "$apache_user",
        group => "$apache_user",
        mode => "0600",
    }


    apache::vhost::redirect { "$journalist_ip":
       port => '80',
       dest => "https://$journalist_hostname.$domain_name",
       vhost_name => $journalist_ip,
    }

    apache::vhost { "ssl_$journalist_ip":
       priority => '25',
       vhost_name => $journalist_ip,
       port => '443',
       servername => "$journalist_hostname.$domain_name",
       serveraliases => "www.$journalist_hostname.$domain_name",
       docroot => "$deaddrop_home/static",
       options => 'None',
       template => 'deaddrop/vhost-deaddrop-ssl.conf.erb',
    #   before => File["$deaddrop_home"],
    }

#    vcsrepo { "$deaddrop_home":
#        ensure => present,
#        provider => git,
#        source => 'git://github.com/deaddrop/deaddrop.git',
#        before => File["$deaddrop_home/store"],
#    }

    file { "$deaddrop_home":
        ensure => directory,
        recurse => true,
        owner => "$apache_user",
        group => "$apache_user",
        mode => '0600',
        source => "puppet:///modules/deaddrop/deaddrop",
        before => File["$deaddrop_home/store"],
    }

    file {"$deaddrop_home/store":
        ensure => directory,
        owner => "$apache_user",
        group => "$apache_user",
        mode => "0700",
        before => File["$deaddrop_home/keys"],
    }

    file {"$deaddrop_home/keys":
        ensure => directory,
        owner => "$apache_user",
        group => "$apache_user",
        mode => "0700",
        before => File["$deaddrop_home/config.py"],
    }

    file { "$deaddrop_home/config.py":
        ensure => file,
        owner => "$apache_user",
        group => "$apache_user",
        mode => '0600',
        content => template("deaddrop/config.py.erb"),
        before => File["$deaddrop_home/web"],
    }

    vcsrepo { "$deaddrop_home/webpy":
        ensure => present,
        provider => git,
        source => 'git://github.com/webpy/webpy.git',
        before => File["$deaddrop_home/web"],
    }
 
    exec { "git clone git://github.com/webpy/webpy.git":
        cwd => '/var/www/deaddrop/',
        user => "$apache_user",
        group => "$apache_user",
    }

    file { "$deaddrop_home/web":
        ensure => 'link',
        target => "$deaddrop_home/webpy/web",
        owner => "$apache_user",
        group => "$apache_user",
    }

    file { "/etc/ssl/journalist_certs/":
        ensure => directory,
        recurse => true,
        owner => 'root',
        group => 'root',
        mode => '0400',
        source => "puppet:///modules/deaddrop/journalist_certs/",
    }

    file { "/var/www/$app_gpg_pub_key":
        ensure => file,
        owner => "$apache_user",
        group => "$apache_user",
        mode => '0700',
        source => "puppet:///modules/deaddrop/${app_gpg_pub_key}",
    }

    exec {"import_key":
        command => "gpg2 --homedir $keys_dir --import /var/www/$app_gpg_pub_key",
        cwd => $keys_dir,
        user => $apache_user,
        group => $apache_user,
        subscribe => File["/var/www/$app_gpg_pub_key"],
        refreshonly => true,
    }

    file { "/var/www/deaddrop/static":
        ensure => present,
        owner => "$apache_user",
        group => "$apache_user",
        mode => '0700',
    }
}
