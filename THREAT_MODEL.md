#DeadDrop Threat Model  
---------------------  

##Application Name and Description  
DeadDrop is meant to let sources communicate with journalists with greater anonymity and security than afforded by conventional e-mail.


##Business Objectives  
* Design an application that provides a source a way to securely upload documents and messages to a journalist that protects the source's anonymity.  
* Design an environment to host the application that protects the source's anonymity.  
* The application should allow for the source to return to the site and check for replies from the journalist.  
* The application and environment should be designed so only the selected journalists can decrypt the source's encrypted documents and files.  
* The application and environment should be designed so only the intended source can view the journalist's clear text replies.  
* The source's authentication mechanism, while being secure, should be easy for the source to remember without writing down. 
* The application and environment should use well known and industry accepted cryptography and security practices.  
* The environment should be monitored for possible security events though identifiable information about the source should be excluded from all logs in the environment.  
* The application and environment should be designed to protect the encrypted files even in the event of a full system compromise or seizure.  


##Anonymity Provided
* A Tor hidden service is configured for the application. It is highly recommended for the source to use Tor to submit messages, documents and check for replies. Please consult this link for more information on Tor and Tor hidden services https://www.torproject.org/docs/hidden-services.html.en  
* Only the two selected journalists have physical access to the application's GPG private key and know the key's passphrase used to decrypt source files. These steps were taken to provide reasonable assurance that only the two selected journalists could decrypt the files after they were encrypted in the application.   
* The network firewall only detects the tor traffic not information about the source.  
* Apache access logs are not kept.  
* The source's clear text code name is not stored to disk in the application or known to the site administrators and journalists.  
* The source's uploaded messages and documents are encrypted before being stored to disk.  
* The secure viewing station is where the application's GPG private keys decrypts the source's submitted information and is 1) never connected to a network, 2) booted from a LiveCD, 3) the hard drive is removed, 4) physically located in a secured corporate facility.  
* Journalist's reply messages to sources are encrypted with a GPG keypair unique to the source.  
* Journalist's replies are encrypted with a gpg passphrase that is only known to the source and never stored in clear text in the application.   
* The source is urged to delete replies after reading them. The application uses secure-remove to delete the file and it is not reasonably forensically recoverable.
* To ensure that the physical devices are not tampered with the network firewalls, source interface, journalist interface and monitors servers are located in a corporate owned facility (not a co-location hosting provider or cloud provider).   *The environment is physically monitored 24/7 with strict access policies.  

##Application Usage  
###Source's Role  
(S1) The organization's Tor hidden service URL, directions, and links to the Tor single-purpose browser are displayed organization's website. The source downloads and installs the Tor single-purpose browser from https://torproject.org. The source uses the site's hidden service URL (.onion) to use the application with a higher level of anonymity than a HTTPS url can provide.  

(S2) A link to the privacy statement is provided.  

(S3) Upon hitting 'Submit,' a codename is generated for the individual source. The source is instructed to memorize the clear text codename. The codename is used to identify individual sources on return visits to view replies and follow up with the journalist.  

(S4) The application creates a sha256 hash of the clear text codename. The clear text codename is transmitted in each protected resource's POST request which is verified against the sha256 hash that is stored to disk that authorizes the source to access the requested resource. That authorization process is performed on each individual POST request to a protected resource.  

(S5) Once the source is authenticated, using the hash of the clear text codename, the application checks to see if a GPG v2 keypair was previously created for the source's hashed codename. If a keypair was not previously created, the application generates a unique keypair for the specified hashed codename. The source interface has the rng-tools package installed and configured to use an external random number generator device for the source of entropy in the key generation. The source’s clear text codename is used as the sources gpg keypair secret passphrase which is not stored to disk in clear text.  

(S6) The source can then upload a file, enter a message, view and delete replies from the journalist.  

(S7) If a message was uploaded, the string is utf8-encoded and then encrypted with the application's GPG public key. The encrypted message is stored in the individual's source's hashed codename directory.  

(S8) If a document is uploaded, a background lambda** process is started in order to handle the upload and encryption process. The encrypted document is stored in the unique source's hashed codename directory.  

(S9) If a reply message from a journalist is stored in the source's hashed codename directory, the source is presented a link to decrypt the reply. A warning is presented to the source, advising them to delete the message after viewing it. This is done to limit the source's exposure, should their codename ever be compromised. To decrypt the message, the application queries the GPG keyring for the source's private GPG key using the hashed codename. The source's GPG passphrase is the clear text codename (which the application never stores to disk, but is passed in the source's POST request for protected resources.)  

(S10) Once the message is displayed, the source is provided the option to delete it per the previous warning. The secure-delete package's srm command is used to securely wipe the journalist's encrypted message from the source's encrypted file store.  

###Journalist's Role  
(J1) From the journalist's workstation, the journalist VPNs into the tips environment through a VPN tunnel that does not allow split-tunneling and has been configured for 2-factor authentication. The journalist interface requires SSL client certificates for access. The journalist will need to have their user certificate installed into their browser to access the journalist interface.  

(J2) Once the journalist's SSL user certificate is validated, the journalist is presented a list of source code IDs that have submitted documents. The source code IDs that are presented to the journalist is a different 3-word code IDs from the source’s clear text codename. The application generates the separate code IDs using the hashes of the sources’ codenames. This is done so that the source's clear text codename is not known to the journalist. A journalist will not request the source’s clear text codename and the source should not include it in any uploaded files or messages. 

(J3) The journalist can select a code ID and is presented a list of encrypted files to download.  

(J4) The journalist will download the encrypted files to application's external hard drive.  

(J5) The journalist then walks the application's external hard drive (with the encrypted files saved to it) over to the Secure Viewing Station (SVS) that is never connected to a network to decrypt and view the submitted information.  

(J6) The SVS is a workstation that is booted from a LiveCD with the hard drive removed to limit its attack surface to persistent threats. It is never connected to any wired or wireless networks, to prevent a remote attacker from accessing it. The source then inserts the application's external hard drive into the booted SVS and transfers the encrypted files to the SVS desktop. After the transfer is complete, the journalist should securely delete the encrypted file from the external hard drive and remove the drive. After the application's external hard drive is removed from the SVS, the journalist should insert application's secure keydrive that contains the application's private GPG key and the journalist’s personnel public key into the SVS. The journalist should then decrypt the files using the application's private GPG key. The journalist can then proceed validating the submitted documents. When the journalist's session is over, they should remove the application's secure keydrive, power down the SVS, and securely store all components. Only the selected journalists should know the passphrase and physical access to the application's GPG private key.  

(J7) For scenarios where a journalist requires part of the unencrypted contents of submitted information for publication, the journalist should encrypt the clear text contents using their personal GPG keypair – not the application's keypair, on the secure viewing station before transferring them to their personnel workstation. The source's documents and messages should be encrypted at rest until the article is ready for publication.  

(J8) The journalist's interface also has a reply function. The journalist can enter their message for a specific source into a text box and click 'Submit.' The application retrieves the source's GPG public key based off of the source's hashed codename. If the journalist cannot access the source's GPG public key, the reply function is not rendered. The application encrypts the journalist reply with a unique source's GPG public key, which is stored in the source's hashed codename-encrypted file store.  

##Authentication    
* VPN authentication requires 1) username, 2) follows the organization's password complexity policy, and 3) requires 2-factor authentication such as the one from DUO Security.  

* Admin SSH access should require 1) 2-factor authentication, such as Google 2-factor pam module, 2) following the organization's policy for password complexity, and 3) access restricted to the admin's internal vpn address.  

* The DeadDrop password-less ECDSA 4096-bit length keyfile used for the sshfs mount, should restrict logins to the journalist server from the source server, and restrict the user to sshfs commands only.  

* The OSSEC manager and agents use generated server and client SSL certificates, which authenticate and encrypt the traffic.  

* The OSSEC manager should be configured to use an authenticated SMTP relay  

* The journalist site and user SSL certificates should be generated on the standalone Local CA workstation.  
  
* User certificates to access the journalist interface, restricted to the journalist's internal VPN address  
 
* All GPG keypairs are GPG v2, RSA, 4096-bit length keys with unique passphrase.  

* The application's GPG private key should only be generated and stored on application's secure keydrive inserted into the SVS when in use, otherwise stored in a secure location.  

* The codename is derived by using “system.random” to randomly choose 3 words from the pre-defined word list file.  It is supplied by the source in each request to a protected resource to authenticate. It is also used as the source's GPG passphrase. The clear text codename is not stored to disk in clear text at any point.  

* A sha256 hash using the HMAC secret, which the admin defined in the configuration file, is made of the source's clear text codename. The source's hashed codename is used as the source's encrypted file store directory and as part of the source's GPG keypair's email address.  

* On POST requests to protected resources, the application will hash the value passed from the source in the codename field and compare it to the source's encrypted file store directory names. If the hashed value from the source matches the name a of a directory then the source is authenticated as that source.  

* Admin access to the network firewall should be restricted to the admin's internal VPN IP address.  

##Security Monitoring  
* Security email alerts are sent to the configured admin distribution email address in the puppet config.  
* VPN User access  
* Network firewall configuration changes  
* Tor error log  
* SSH access (includes SSHFS access and google's 2 factor pam module)  
* OSSEC agent and manager activity    
* Grsecurity events  
* AppArmor events  
* Host-based firewall events (excluding external drops on the network firewall device)  
* New network connections (excluding the source interface servers HTTP and HTTPS ports)  
* Real time file integrity changes  
* Apparmor policy violations  
* Grsecurity kernel violations  
* The Journalist interface access and error events  
* Disk space monitoring  
* Memory and CPU monitoring  
* Process monitoring  
* “Is it up” site monitoring should be performed with a tool that does not require an agent to be installed in the environment to limit the attack surface.  


##Security Mailing Lists  
Network Firewall ____________________  
DeadDrop https://github.com/deaddrop  
Tor https://lists.torproject.org/cgi-bin/mailman/listinfo/tor-announce/  
Apache2 http://httpd.apache.org/lists.html#http-announce  
mod_wsgi https://groups.google.com/forum/?fromgroups#!forum/wsgi-security-announce  
web.py https://groups.google.com/forum/?fromgroups#!forum/webpy  
python-gnupg library http://groups.google.com/group/python-gnupg  
python 2.7 http://www.python.org/news/security/ create a change alert for this page  
gnupg2 package http://lists.gnupg.org/pipermail/gnupg-announce/  
Openssl http://www.openssl.org/support/community.html (enter email address)  
Google's 2FA pam module http://code.google.com/p/google-authenticator/ (join group)  
Grsecurity http://grsecurity.net/cgi-bin/mailman/listinfo/grsecurity  
OSSEC http://www.ossec.net/?page_id=21#ossec-list (send email request to join)  
AppArmor https://lists.ubuntu.com/mailman/listinfo/apparmor  
Ubuntu 12.04 https://lists.ubuntu.com/mailman/listinfo/ubuntu-security-announce  


