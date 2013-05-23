class ssh {
    # Declare:
    @@sshkey { $hostname:
        type => rsa,
        key => $sshrsakey,
        size => '4096',
    }
    # Collect:
    Sshkey <<| |>>
}
