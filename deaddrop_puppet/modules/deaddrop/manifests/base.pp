class deaddrop::base {
    include ntp
    include gnupg2
    include secure_delete
    include sysstat
    include deaddrop::ssh
    include deaddrop::iptables_v4
    include deaddrop::sysctl
    include deaddrop::restricted_pw_files
#    include deaddrop::remove_pcmcia
    include deaddrop::cron_allow
    include deaddrop::crontab

    package { "syslog-ng": ensure => installed}   
    package { "libpam-google-authenticator": ensure => installed}
}
