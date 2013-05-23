class deaddrop::source_deaddrop {
    include git

    file {"/var/www":
        ensure => directory,
        owner => "$apache_user",
        group => "$apache_user",
        mode => "0600",
    }

    file {"/var/www/.ssh":
        ensure => directory,
        owner => "$apache_user",
        group => "$apache_user",
        mode => "0600",
    }

#    vcsrepo { "$deaddrop_home":
#        ensure => present,
#        provider => git,
#        source => 'git@github.com:deaddrop/deaddrop.git'
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
#        before => VCSREPO["$deaddrop_home/webpy"],
    }

#    vcsrepo { "$deaddrop_home/webpy":
#        ensure => present,
#        provider => git,
#        source => 'git://github.com/webpy/webpy.git',
#    }
 
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
#        subscribe => Vcsrepo["$deaddrop_home/webpy"],
    }
    file { "$deaddrop_home/static":
        ensure => present,
        owner => "$apache_user",
        group => "$apache_user",
        mode => '0700',
    }
}

