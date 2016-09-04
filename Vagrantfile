Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
  config.ssh.forward_agent = true

  config.vm.provision "puppet", type: "shell", inline: PUPPET
  config.vm.define "ubuntu-14.04" do |node|
  end
end

PUPPET = <<SCRIPT
  apt-get update -y
  apt-get install -y puppet-common
  puppet module install puppetlabs-apt
  puppet module install puppetlabs-java_ks
  ln -s /vagrant /etc/puppet/modules/dellomsa

  cd /etc/ssl/private/
  openssl genrsa -out omsa.host.tld.key 2048 2> /dev/null
  openssl req -new -x509 -key omsa.host.tld.key -out omsa.host.tld.crt -days 3650 -subj /CN=omsa.host.tld
  ln -s omsa.host.tld.crt omsa.host.tld.inter
  cd -

  cat << EOF > /root/dellomsa.pp
class { dellomsa:
  development => true,
  keystore_password => 'SomeRandomPasswordHere',
  ssl_certificate => '/etc/ssl/private/omsa.host.tld.crt',
  ssl_chain => '/etc/ssl/private/omsa.host.tld.inter',
  ssl_private_key => '/etc/ssl/private/omsa.host.tld.key',
}
EOF
  puppet apply /root/dellomsa.pp
  true
SCRIPT
