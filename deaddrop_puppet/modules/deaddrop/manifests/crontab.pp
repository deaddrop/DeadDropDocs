class deaddrop::crontab {
    file { "/etc/crontab":
        ensure => present,
        mode => '0400',
    }

    file { "/var/spool/cron":
        ensure => directory,
        recurse => true,
        mode => '0700',
    }
}
