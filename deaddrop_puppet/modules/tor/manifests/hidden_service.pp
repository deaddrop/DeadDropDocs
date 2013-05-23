class tor::hidden_service {
   include tor

   file { '/etc/tor/torrc':
      ensure => file,
      source => "puppet:///modules/tor/torrc",
      owner => 'root',
      group => 'root',
      mode => '0644',
      require => Package["tor"],
   }

   service { 'tor':
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      subscribe => File['/etc/tor/torrc'],
   }

   exec { 'passwd -l debian-tor':
      user => 'root',
      group => 'root',
   }
}
