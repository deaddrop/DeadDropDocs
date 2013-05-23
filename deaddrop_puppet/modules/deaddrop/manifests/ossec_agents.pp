class deaddrop::ossec_agents {
    file { 'ossec.conf':
      ensure => file,
      path => '/var/ossec/etc/ossec.conf',
      content => template("deaddrop/$my_role.ossec.conf.erb"),
      owner => 'root',
      group => 'ossec',
      mode => '0550',
    }
}

