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
  true
SCRIPT
