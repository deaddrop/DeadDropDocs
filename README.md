Deaddrop Environment Install Guide
===========

Deaddrop is a tool for communicating securely with journalists. Please also view the Threat_Model.doc, diagram.jpg, and design.jpg in docs/ for more information. The environment install guide is below the license. 

Copyright (C) 2011-2012.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

##Local Certificate Authority Install  
The Local CA should not be a host connected to a network. Before removing the hard drive from the SVS configure it as the Local CA.  
1. Configure the SVS hard drive as the Local CA  
2. The Ubuntu 12.04 install should be configured to use the LUKS full disck encryption by using the alternate install cd  
3. Generate the needed certificates and revocation file using the steps below  
4. Distribute the certificates as needed  
5. Remove the hard drive configured as the Local CA from the SVS shell  
6. Store the hard drive configured as the Local CA in a secure safe only accessible by the approved journalists  
7. Only when needed to create or revoke certificates for the journalist's interface does the hard drive need to be placed back in the SVS laptop shell  
 
###Setup openssl
You can use different directory structure and filenames, just ensure that they are changed throughout the installation and puppet manifests where needed.  

	sudo apt-get update  
	sudo apt-get upgrade -y  
	mkdir -p /opt/tipsCA/{private,newcerts,certs,usercerts,crl}  
	touch /opt/tipsCA/index.txt  
	echo '01' > /opt/tipsCA/serial  
	echo '01' > /opt/tipsCA/crlnumber  
	cd /opt/tipsCA    

Edit **/usr/lib/ssl/openssl.cnf**  

	nano /usr/lib/ssl/openssl.cnf  

>[CA_default]  
>dir             = /opt/tipsCA               # Where everything is kept  

####Generate the needed certificates
Generate the CA cert and revocation list:  

	openssl ecparam -name secp256r1 -genkey -out private/cakey.pem  
	openssl req -x509 -extensions v3_ca -sha256 -new -key private/cakey.pem -out certs/cacert.pem -days 3650  
	openssl ca -gencrl -keyfile private/cakey.pem -cert certs/cacert.pem -out crl/cacrl.pem -crldays 90  

Generate the Journalist's Interface certs:  

	openssl genrsa -out private/journalist.key.pem 4096  
	openssl req -sha256 -new -nodes -key private/journalist.key.pem -out newcerts/journalist.req.pem -days 365  
	openssl ca -keyfile private/cakey.pem -cert certs/cacert.pem -in newcerts/journalist.req.pem -out certs/journalist.cert.pem  
	openssl x509 -in certs/journalist.cert.pem -text -noout  
	openssl rsa -in private/journalist.key.pem -out private/journalist.without.key  

Generate the user certificates for admins and journalists that will require access to the journalist interface. Convert the certs to pkcs12 format to import into browsers.  

	openssl genrsa -out private/first_last_name.key.pem 4096  
	openssl req -sha256 -new -nodes -key private/first_last_name.key.pem -out newcerts/first_last_name.req.pem -days 365  
	openssl ca -keyfile private/cakey.pem -cert certs/cacert.pem -in newcerts/first_last_name.req.pem -out usercerts/first_last_name.cert.pem  
	openssl pkcs12 -export -in usercerts/first_last_name.cert.pem -inkey private/first_last_name.key.pem -out usercerts/first_last_name.p12 -name "first_last_name"  
	chmod 0400 /opt/tipsCA/*/*.pem  

Copy the needed certs to the app's external harddrive  

	cd /opt/tips  
	cp private/journalist.wo.key.pem ~/journalist_certs/  
	cp crl/cacrl.pem ~/journalist_certs/  
	cp certs/{cacert.pem,journalist.cert.pem} ~/journalist_certs/  

##Configure Secure-Viewing-Station and Application's GPG keypair

###Create Ubuntu LiveCD and prepare the SVS  
https://help.ubuntu.com/community/LiveCD  
Remove the hard drive containing the Local CA (after copying the generated certificates to the monitor server)  
Boot from the SVS from the LiveCD   

###Create the Application's GPG keypair  
Insert the app's secure keydrive into the SVS  
Use an external hard drives rather than a external flash drives. A GPG v1 key will not work with the DeadDrop application. gnupg2 is not required to decrypt messages and files, only to create keys. Use an external entropy device when possible, if one is not available use /dev/random  

####Install required dependencies and create the gpg v2 keys

	apt-get install gnupg2 secure-delete rng-tools -y  
	
Edit /etc/default/rng-tools, if you have an external entropy key use it instead of dev/random  

	nano /etc/default/rng-tools  
	
>\# Set to the input source for random data, leave undefined  
>\# for the initscript to attempt auto-detection.  Set to /dev/null  
>\# for the viapadlock driver.  
>\#HRNGDEVICE=/dev/hwrng  
>\#HRNGDEVICE=/dev/null  
>**HRNGDEVICE=/dev/random**  

Start rng_tools to provide create a larger entropy source  

	/etc/init.d/rng-tools start  
	
Generate the gpg v2 keys  

	gpg2 --homedir  */set this to path on the secure keydrive/* --gen-key  
	
>(1) RSA and RSA (default)  
>key size: 4096  
>real name: Journalist  

Only the two selected journalist's should know the app's GPG keypair's passphrase. Follow your organization's password policy. http://howto.wired.com/wiki/Choose_a_Strong_Password  

Export the Journalist's gpg public key  

	gpg2 --export --output journalist.acs --armor Journalist  

####Determine and record the application's gpg key's fingerprint  

	gpg --homedir /deaddrop/keys --list-keys  
	gpg --homedir */location set in earlier step/* --edit-key "Journalist_name_from_list"  

You will get a prompt like `Command>` type `fpr` and hit enter  
it will then show you the key's fingerprint. It should look like the line below. Record it somewhere for use in the puppet nodes.pp file.  

	CCCC CCCC CCCC CCCC CCCC  CCCC CCCC CCCC CCCC CCCC  

##Install and configure puppet
Puppet is used to install the deaddrop application and configure the environment. Efforts were taken to apply the secrity hardening steps. To keep the attack surface to a minimum uninstall puppet after the environment is configured.
https://help.ubuntu.com/12.04/serverguide/puppet.html

###Monitor Server
-----------  
####Set the hostname if not already done  

	nano /etc/hostname  
	
>monitor.domain_name  

	hostname -F /etc/hostname  

####Edit the /etc/hosts file  
It should look something like below  

	nano /etc/hosts  
	
>127.0.0.1       localhost puppet  
>127.0.1.1       ubuntu
>
>xxx.xxx.xxx.xxx source.domain_name    source  
>xxx.xxx.xxx.xxx journalist.domain_name    journalist  
>xxx.xxx.xxx.xxx monitor.domain_name    monitor  
>xxx.xxx.xxx.xxx intvpn.domain_name    intvpn  
>xxx.xxx.xxx.xxx intfw.domain_name    intfw  

####Install the puppetmaster and dependencies  
When promted during iptables-persistent install hit *yes* for the IP address version you are using. This guide uses IPv4 enter **yes** when prompted.  

	sudo apt-get install puppetmaster iptables-persistent rubygems sqlite3 libsqlite3-ruby git -y  
	cd /etc/puppet/modules  
	gem install puppet-module  
	gem install rails -v 2.2.2   
	puppet module install puppetlabs-firewall  
	puppet module install puppetlabs-ntp  
	puppet module install puppetlabs-vcsrepo  
	puppet module install puppetlabs-apt  
	puppet module install puppetlabs-git  
	puppet module install puppetlabs-stdlib   
	puppet module install puppetlabs-apache  
	
If you get a **Invalid version format: 0.5.0-rc1** error then download the module manually:  

	wget http://forge.puppetlabs.com/puppetlabs/apache/0.5.0-rc1.tar.gz  
	tar -xzf 0.5.0-rc1.tar.gz  
	mv puppetlabs-apache-0.5.0-rc1 apache  

Clone the deaddrop_puppet repo which contains the rest of the manifests and modules needed. Put them in the correct directories. These modules were not done to puppet style guide. Currently in the process of improving them and making them compliant. At some point we hope to have them hosted on puppet forge but till then use at your own risk and please help out if you are a puppet guru.   

	git clone https://github.com/deaddrop/deaddrop_puppet  
	cp deaddrop_puppet/manifests/* /etc/puppet/manifests/  
	cp deaddrop_puppet/modules/* /etc/puppet/modules/


Edit **/etc/puppet/puppet.conf** adding the following lines:  

	nano /etc/puppet/puppet.conf  
	
>storeconfigs = true  
>thin_storeconfigs = true  
>dbadpter = sqlite3  

####Gather the required files from the external harddrives  
From the Secure Viewing Station's:  
App's pub gpg key `/etc/puppet/modules/deaddrop/files`  

From the Local Certificate Authority:  
Journalist Interface's SSL cert `/etc/puppet/modules/deaddrop/files/journalist_certs/`  
Journalist Interface's SSL private key `/etc/puppet/modules/deaddrop/files/journalist_certs/`  
Local CA's root CA cert `/etc/puppet/modules/deaddrop/files/journalist_certs/`  
Local CA's CRL list `/etc/puppet/modules/deaddrop/files/journalist_certs/`

#####Modify the default parameters  
Modify parameters and hostnames the first section of nodes.pp manifest  

	nano /etc/puppet/manifests/nodes.pp  

>node basenode {  
>\# These values will need to be changed to reflect your environment  
>    $domain_name                 = 'domain_name.com'  
>    $source_ip                   = 'xxx.xxx.xxx.xxx'  
>    $source_hostname             = 'source'  
>    $journalist_ip               = 'xxx.xxx.xxx.xxx'  
>    $journalist_hostname         = 'journalist'  
>    $monitor_ip                  = 'xxx.xxx.xxx.xxx'  
>    $monitor_hostname            = 'monitor'  
>    $admin_intVPN_ip             = 'xxx.xxx.xxx.xxx'  
>    $admin_intVPN_hostname       = 'intVPN'  
>    $journalist_intVPN_ip        = 'xxx.xxx.xxx.xxx'  
>    $journalist_intVPN_hostname  = 'intVPN'  
>    $intFWlogs_ip                = 'xxx.xxx.xxx.xxx'  
>    $intFWlogs_hostname          = 'intFWlogs'  
>    $puppetmaster_hostname       = 'monitor'  
>    $app_gpg_pub_key             = 'journalist.acs'  
>    $hmac_secret                 = 'use_a_random_number_generater_for_this_value'  
>    $app_gpg_fingerprint         = 'XXXX XXXX XXXX XXXX XXXX  XXXX XXXX XXXX XXXX XXXX'  
>    $mailserver_ip               = 'gmail-smtp-in.l.google.com'  
>    $ossec_emailto               = 'user_name@gmail.com'  

####Restart the puppetmaster

	/etc/init.d/puppetmaster restart

###Install Puppet on the Source and Journalist servers  

	apt-get install puppet iptables-persistent  
	
Edit /etc/hosts file to look like below:  

>127.0.0.1       localhost  
>127.0.1.1       ubuntu  
>
>xxx.xxx.xxx.xxx source.domain_name source  
>xxx.xxx.xxx.xxx journalist.domain_name journalist  
>xxx.xxx.xxx.xxx monitor.domain_name monitor puppet  
>xxx.xxx.xxx.xxx intvpn.domain_name intvpn  
>xxx.xxx.xxx.xxx intfw.domain_name intfw  

Edit /etc/default/puppet change “START=no” to look like below  

>\#  Start puppet on boot?  
>START=yes  

Start the puppet agent on the source and journalist server  

	/etc/init.d/puppet restart  

###Sign the puppet agent certs on the Monitor server  

	puppetca --list --all   
	puppetca --sign --all

###Run the puppet manifest to configure the environment  
Run puppet on the 1) monitor server, 2) journalist interface server, 3) source interface server  

	puppet agent --server monitor.domain_name -t  
	
##Steps for the system admins to create keys for Google's 2 Step Authenticator PAM module  
Ensure that you are not root. Each user that needs SSH access will need to perform these steps. The same key can be used for all devices in the same environment. If the ios/android device and the servers are more than 30 seconds off the codes will not work. Currently the puppet manifest only downloads and partially install google-authenticator it does not enable it. Was worried that people may lock themselves out. You can read more about it at https://code.google.com/p/google-authenticator/    

###Each admin should create their own code  
1. Create the code  

	cd ~  
	google-authenticator  

>y  
>y  
>y  
>n  
>y  

2. To set up you ios or android device install the 'google authenticator' app from the respective official app stores.  
3. Open the app and click 'add key manually'  
4. On the server run \# `cat ~/.google-authenticator` The first line is your key. Enter that exactly into the google-authenticator app  
5. Edit **/etc/ssh/sshd_config** and change **ChallengeResponseAuthentication** from **no** to **yes**

>ChallengeResponseAuthentication yes  

6. Edit /etc/pam.d/common-auth  and add  **auth    required	pam_google_authenticator.so** so that it will look like the following  

>here are the per-package modules (the "Primary" block)  
>auth    required                        pam_google_authenticator.so  
>auth    [success=1 default=ignore]      pam_unix.so nullok_secure  

7. Restart ssh and test it in a new connection. Do not close or log out of the current window  

	/etc/init.d/ssh restart  
	
8. Open a new terminal window and ssh into the server and verify you can login. do not close the other window until after you verified that you still have access.  
9. Copy you secret key to the other hosts with a command like this one  

	scp /home/user_name/.google-authenticator user_name@source:.  

##Create a grsec patched kernel with the ubuntu-precise overlay .deb package  
The grsecurity wikibook should be read throughly.  
http://en.wikibooks.org/wiki/Grsecurity  
The steps for creating a grsec patched kernel with a ubuntu overlay were based from the following link. Please read that blog post for more information.  
http://compilefailure.blogspot.com/2011/02/grsecurity-patched-ubuntu-server-lts.html  

###Gather files and packages needed for the ubuntu overlay  

	cd ~  
	mkdir grsec  
	cd grsec  
	apt-get install libncurses5-dev build-essential  kernel-package git-core -y  
	git clone git://kernel.ubuntu.com/ubuntu/ubuntu-precise.git  
	cp -a /usr/share/kernel-package ubuntu-package  
	cp ubuntu-precise/debian/control-scripts/p* ubuntu-package/pkg/image/  
	cp -a /usr/share/kernel-package ubuntu-package  
	cp ubuntu-precise/debian/control-scripts/p* ubuntu-package/pkg/image/  
	cp ubuntu-precise/debian/control-scripts/headers-postinst ubuntu-package/pkg/headers/  

Install gcc-(version)-plugin-dev.   
This package is needed by the grsec patch.  

	apt-get install gcc-4.6-plugin-dev -y    

Download the kernel and grsecurity patch 
Check the grsecurity.net website and use the current stable version. The grsec/kernel were current at the time of writing.
\“All grsecurity packages have a version string in their names. It contains both the version of the release itself and the kernel version it is meant for. For example, the version string 2.2.2-2.6.32.45-201108262310 tells us that the version of this grsecurity release is 2.2.2 and it is meant for kernel version 2.6.32.45. The last section of the version is a timestamp.\”  
	- http://en.wikibooks.org/wiki/Grsecurity/Obtaining_grsecurity#Downloading_grsecurity

	wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.36.tar.bz2  
	wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.36.tar.sign  
	wget http://grsecurity.net/spender-gpg-key.asc  
	wget http://grsecurity.net/stable/grsecurity-2.9.1-3.2.36-201301032034.patch  
	wget http://grsecurity.net/stable/grsecurity-2.9.1-3.2.36-201301032034.patch.sig  

Verify the packages  

	gpg --import spender-gpg-key.asc
	gpg --verify grsecurity-2.9.1-3.2.36-201301032034.patch.sig  
	gpg --recv-keys 6092693E  
	bunzip2 linux-3.2.36.tar.bz2  
	gpg --verify linux-3.2.36.tar.sign  

###Apply the patch to the kernel and make the grsec kernel

	tar -xf linux-3.2.36.tar  
	cd linux-3.2.36  
	patch -p1 <../grsecurity-2.9.1-3.2.36-201301032034.patch  

Apply the old hardware config to ensure that the correct options are retained

	yes "" | make oldconfig  
	make menuconfig  
	
In the gui:

>- navigate to 'Security options'  
>- navigate to 'Grsecurity'  
>- enable the ‘Grsecurity’ option  
>- Set ‘Configuration Method’ to ‘Automatic’  
>- Set ‘Usage Type’ to ‘Server’  
>- Set ‘Virtualization Type’ to ‘None’  
>- Set ‘Required Priorities’ to ‘Security’  
>- navigate to ‘Customize Configuration’  
>- navigate to ‘Sysctl Support’ and enable ‘Sysctl support’  
>- exit and save changes  

	make-kpkg clean  
	make-kpkg --initrd --overlay-dir=../ubuntu-package kernel_image kernel_headers  

Grab a cup of coffee. When the package is complete scp the .deb files to all the servers.  
###Resolve PAX grub issues    

	apt-get install paxctl -y  
	paxctl -Cpm /usr/sbin/grub-probe  
	paxctl -Cpm /usr/sbin/grub-mkdevicemap  
	paxctl -Cpm /usr/sbin/grub-setup  
	paxctl -Cpm /usr/bin/grub-script-check  
	paxctl -Cpm /usr/bin/grub-mount  
	update-grub  

###Install the grsec patched kernel  

	cd ..  
	dpkg -i *.deb  


Review boot menu and boot into new kernel  
Verify that `/boot/grub/menu.lst` has the correct values. Make adjustments as necessary.  

	sudo reboot 

After the reboot check that you booted into the correct kernel.   

	uname -r  

It should end in '-grsec'  

##Clean up the system and puppet firewall rules  
Once the environment is verified, uninstall puppet on the puppetmaster and puppet agents to decrease the attack surface  

	apt-get purge rubygems puppetmaster puppet gcc make libncurses5-dev build-essential  kernel-package git-core g++ python-setuptools sqlite3 libsqlite3-ruby  

Remove the puppet rule from the monitor server in /etc/iptables/iptables_v4 file  

	iptables-restore < /etc/iptables/iptables_v4  

Due to Puppet bug 1737 you will need to either apply this fix linked to below or manually restrict the ssh options for www-data public key on the journalist server
http://projects.puppetlabs.com/issues/1737  
Fix #1737 - ssh_authorized_keys should be able to parse options conta…  
https://github.com/masterzen/puppet/commit/d9f40be12fe0d25c11d76129ee64fa1f70507d05  

the options preceding the apache user's ssh key file should look like below:  

	from=\"source\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty  
