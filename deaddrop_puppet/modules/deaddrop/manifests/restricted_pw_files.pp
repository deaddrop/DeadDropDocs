class deaddrop::restricted_pw_files {
     file { "/etc/passwd":
         ensure => present,
         mode => '0644',
     }

     file { "/etc/group":
         ensure => present,
         mode => '0644',
     }

    file { "/etc/shadow":
        ensure => present,
        mode => '0400',
    }
}   
