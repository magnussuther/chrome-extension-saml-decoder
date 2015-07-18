cd /home/vagrant/

# Enable HTTPS for apt.
apt-get update
apt-get install apt-transport-https -y
apt-get install curl -y

# Get the Google Linux package signing key.
sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'

# Set up the location of the stable repository.
sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
apt-get update

apt-get install dart -y


# Install WebStorm IDE. Run WebStorm.sh from the bin subdirectory
apt-get install default-jdk -y
if [ ! -f /home/vagrant/WebStorm-10.0.4.tar.gz ]; then
  wget https://download.jetbrains.com/webstorm/WebStorm-10.0.4.tar.gz
  tar xvzf WebStorm-10.0.4.tar.gz
fi


# Install Dartium
if [ ! -f /home/vagrant/dartium-linux-x64-release.zip ]; then
  wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/dartium/dartium-linux-x64-release.zip
  unzip dartium-linux-x64-release.zip
  chown -R vagrant:vagrant dartium-lucid64-full-stable-1.11.1.0
fi

if [ ! -f /lib/x86_64-linux-gnu/libudev.so.0 ]; then
  sudo ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
fi

apt-get install git -y
