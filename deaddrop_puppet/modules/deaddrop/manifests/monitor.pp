class deaddrop::monitor {
    $my_role = 'monitor'
    $ossec_role = 'server'

    include deaddrop::hosts_file
    include deaddrop::tcp_wrappers
    include deaddrop::ossec_server
#    include deaddrop::apparmor  
}
