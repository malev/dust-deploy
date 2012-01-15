class UnattendedUpgrades < Recipe
  desc 'unattended_upgrades:deploy', 'installs and configures automatic system updates for debian and ubuntu'
  def deploy
    return unless @node.uses_apt? 
    @node.install_package 'unattended-upgrades'

    @config = {} unless @config.is_a? Hash

    # set defaults for non-set config
    @config['enable'] ||= 1
    @config['update-package-lists'] ||= 1
    @config['unattended-upgrade'] ||= 1
    @config['autocleaninterval'] ||= 1
    @config['verbose'] ||= 0

    # generate configuration file
    periodic = ''
    periodic += "APT::Periodic::Enable \"#{@config['enable']}\";\n"
    periodic += "APT::Periodic::Update-Package-Lists \"#{@config['update-package-lists']}\";\n"
    periodic += "APT::Periodic::Unattended-Upgrade \"#{@config['unattended-upgrade']}\";\n"
    periodic += "APT::Periodic::AutocleanInterval \"#{@config['autocleaninterval']}\";\n"
    periodic += "APT::Periodic::Verbose \"#{@config['verbose']}\";\n"

    @node.write '/etc/apt/apt.conf.d/02periodic', periodic      
  end
end

