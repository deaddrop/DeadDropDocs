class deaddrop::cron_allow {
    file { "/etc/cron.allow":
       ensure => file,
       source => "puppet:///modules/deaddrop/cron.allow",
       mode => '0400',
    }

    file { "/etc/cron.deny":
       ensure => absent,
    }
}
