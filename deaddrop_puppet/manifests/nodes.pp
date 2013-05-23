node basenode {
# These values will need to be changed to reflect your environment
    $domain_name           	 = 'domain_name'
    $source_ip             	 = 'xxx.xxx.xxx.xxx'
    $source_hostname       	 = 'source_hostname'
    $journalist_ip         	 = 'xxx.xxx.xxx.xxx'
    $journalist_hostname   	 = 'journalist_hostname'
    $monitor_ip            	 = 'xxx.xxx.xxx.xxx'
    $monitor_hostname      	 = 'monitor_hostname'
    $admin_intVPN_ip             = 'xxx.xxx.xxx.xxx'
    $admin_intVPN_hostname       = 'intVPN'
    $journalist_intVPN_ip        = 'xxx.xxx.xxx.xxx'
    $journalist_intVPN_hostname  = 'intVPN'
    $intFWlogs_ip           	 = 'xxx.xxx.xxx.xxx'
    $intFWlogs_hostname    	 = 'intFWlogs'
    $puppetmaster_hostname 	 = 'monitor'
    $app_gpg_pub_key       	 = 'journalist.acs' 
    $hmac_secret           	 = 'long random value'
    $app_gpg_fingerprint   	 = 'CCCC CCCC CCCC CCCC CCCC CCCC CCCC CCCC CCCC CCCC'
    $mailserver_ip		 = 'smtp_server'
    $ossec_emailto		 = 'email distribution list that includes journalist'

# The values in this section do not need to be changed
    $apache_name                 =  'apache2-mpm-worker'
    $apache_user                 =  'www-data'
    $sshfs_user                  =  'www-data'
    $deaddrop_home               =  '/var/www/deaddrop'
    $store_dir                   =  "$deaddrop_home/store"
    $keys_dir                    =  "$deaddrop_home/keys"
    $word_list                   =  "$deaddrop_home/wordlist"
    $source_template_dir         =  "$deaddrop_home/source_templates"
    $journalist_template_dir     =  "$deaddrop_home/journalist_templates"
    $docroot_owner      	 =  "www-data"
    $docroot_group      	 =  "www-data"
    include deaddrop::base
}

include ssh::auth
ssh::auth::key { "www-data": }

# Ensure you change the host name from "monitor" to it's actual name
node " the monitor servers hostname" inherits basenode {
    include ssh::auth::keymaster
    include deaddrop::monitor
}

# Ensure you change the host name from "source" to it's actual name
node " the source servers hostname" inherits basenode {
    user { "www-data": }
    ssh::auth::client { "www-data": home => "/var/www" }
    include deaddrop::source
}

# Ensure you change the host name from "journalist" to it's actual name
node " the journalist servers hostname" inherits basenode {
    ssh::auth::server { "www-data": home => "/var/www" }
# temp fix until fix 1737 is applied
#    ssh::auth::server { "www-data": home => "/var/www", options => 'from=\"source\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty' }
    include deaddrop::journalist
}
