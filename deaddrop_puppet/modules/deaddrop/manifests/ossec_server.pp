class deaddrop::ossec_server {
    file { 'ossec.conf':
      ensure => file,
      path => '/var/ossec/etc/ossec.conf',
      content => template("deaddrop/monitor.ossec.conf.erb"),
      owner => 'root',
      group => 'ossec',
      mode => '0550',
    }

    file { 'ossec_rules.xml':
      ensure => file,
      path => '/var/ossec/rules/ossec_rules.xml',
      source => 'puppet:///modules/deaddrop/ossec_rules.xml',
      owner => 'root',
      group => 'ossec',
      mode => '0550',
    }

    file { 'internal_options.conf':
      ensure => file,
      path => '/var/ossec/etc/internal_options.conf',
      source => "puppet:///modules/deaddrop/internal_options.conf",
      owner => 'root',
      group => 'ossec',
      mode => '0440',
    }

   file { 'ossec-logtest':
      ensure => 'link',
      path => '/var/ossec/bin/ossec-logtest',
      target => '/var/ossec/ossec-logtest',
      owner => 'root',
      group => 'root',
   }
}

