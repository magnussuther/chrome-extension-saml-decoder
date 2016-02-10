node 'saml-decoder.vagrantbox.local' {
	exec { "apt-update":
		command => "/usr/bin/apt-get update",
	}
	
	# Whenever a package needs to be installed, this ensures that apt-get update is run first.
	Exec["apt-update"] -> Package <| |>
	
	
	class { 'gnome_desktop': } ->
	
	class { 'devtools': } ->
	
	service { 'gdm':
		ensure => running,
	}
}

class gnome_desktop () {
	# We are installing a minimal Gnome desktop here ...
	package { 'gdm':
		ensure => latest,
		install_options => ["--no-install-recommends"]
	}
	
	# ... so minimal even that we need to install these as well to get a useful GUI
	package {['xserver-xorg', 'gnome-menus']:
		ensure => latest,
	}
}

class devtools () {
	package { ['unzip', # For the Archive resources below
		'terminator', # A proper terminal thingy
		'default-jdk',
		'git', # Required by Dart SDK (for pulling pub packages etc)
		'libxss1' # Required by dartium
		]:
		ensure => latest,
	}
		
	archive { 'dartsdk-linux-x64-release':
		ensure => present,
		extension => zip,
		url => 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.12.0/sdk/dartsdk-linux-x64-release.zip',
		timeout => 0,
		checksum => false,
		follow_redirects => true,
		target => '/home/vagrant/',
		user => 'vagrant',
		src_target => '/tmp',
	}
	
	file { '/etc/profile.d/append-dartsdk-path.sh':
		mode    => 644,
		content => 'PATH=$PATH:/home/vagrant/dart-sdk/bin/',
	}
	
	archive { 'dartium-linux-x64-release':
		ensure => present,
		extension => zip,
		url => 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.14.1/dartium/dartium-linux-x64-release.zip',
		timeout => 0,
		checksum => false,
		follow_redirects => true,
		target => '/home/vagrant/',
		user => 'vagrant',
		src_target => '/tmp',
	}
	
	file { '/usr/local/bin/dartium':
		ensure => link,
		target => '/home/vagrant/dartium-lucid64-full-stable-1.14.1.0/chrome',
	}
	
	file { '/lib/x86_64-linux-gnu/libudev.so.0': # Required by dartium
		ensure => link,
		target => '/lib/x86_64-linux-gnu/libudev.so.1',
	}
	
	$dartium_desktop = "[Desktop Entry]
		Type=Application
		Terminal=false
		Exec=dartium
		Name=Dartium browser
		Comment=Dartium browser
		Icon=/home/vagrant/dartium-lucid64-full-stable-1.14.1.0/product_logo_48.png
		"
	
	file { '/usr/share/applications/dartium.desktop':
		ensure => present,
		content => $dartium_desktop,
	}
	
	archive { 'WebStorm-10.0.4':
		ensure => present,
		url => 'https://download.jetbrains.com/webstorm/WebStorm-10.0.4.tar.gz',
		timeout => 0,
		follow_redirects => true,
		extension => 'tar.gz',
		target => '/home/vagrant/',
		user => 'vagrant',
		checksum => false,
		src_target => '/tmp',
	}
	
	file { '/usr/local/bin/webstorm':
		ensure => link,
		target => '/home/vagrant/WebStorm-141.1550/bin/webstorm.sh',
	}
	
	$webstorm_desktop = "[Desktop Entry]
		Type=Application
		Terminal=false
		Exec=webstorm
		Name=Webstorm IDE
		Comment=Webstorm IDE
		Icon=/home/vagrant/WebStorm-141.1550/bin/webide.png
		"
		
	file { '/usr/share/applications/webstorm.desktop':
		ensure => present,
		content => $webstorm_desktop,
	}
	
	# TODO: Only do this once! Otherwise the license key or whatever gets overwritten!
	archive::extract { 'WebStorm10-config':
		ensure => present,
		timeout => 0,
		target => '/home/vagrant/',
		user => 'vagrant',
		src_target => '/vagrant/puppet/',
	}
}
