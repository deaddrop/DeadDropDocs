# Requrires puppetlabs-apt module
class tor {

    apt::key { "tor":
        key               => "886DDD89",
        key_server        => "keys.gnupg.net",
    }

    apt::source { "tor":
        location          => "http://deb.torproject.org/torproject.org",
        release           => "precise",
        repos             => "main",
        required_packages => "deb.torproject.org-keyring",
        key               => "886DDD89",
        key_server        => "keys.gnupg.net",
        before		  => Package["tor"],
    }

    package { 'tor':
        ensure => "installed",
    }
}
