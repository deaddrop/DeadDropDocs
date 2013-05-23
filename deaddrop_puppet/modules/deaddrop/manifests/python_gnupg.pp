class deaddrop::python_gnupg {
   package { 'python-setuptools':
	 ensure => "installed" 
   }

   exec { 'easy_install https://python-gnupg.googlecode.com/files/python-gnupg-0.2.7.tar.gz':
        cwd => $deaddrop_home,
        user => 'root',
        group => 'root',
        require => Package["python-setuptools"],
        unless => "ls /usr/local/lib/python2.7/dist-packages/python_gnupg-0.2.7-py2.7.egg",
   }
}
