class Newrelic < Recipe
  desc 'newrelic:deploy', 'installs and configures newrelic system monitoring'
  def deploy 
    return Dust.print_failed 'no key specified' unless @config
    return unless @node.uses_apt? :quiet=>false

    ::Dust.print_msg 'updating repositories'
    ::Dust.print_result @node.exec('aptitude update')[:exit_code]

    unless @node.install_package 'newrelic-sysmond'
      ::Dust.print_failed 'installing newrelic monitoring daemon failed, did you setup the newrelic repositories?'
      return
    end

    ::Dust.print_msg 'configuring new relic server monitoring tool'
    return unless ::Dust.print_result @node.exec("nrsysmond-config --set ssl=true license_key=#{@config}")[:exit_code]

    @node.restart_service 'newrelic-sysmond' if options.restart?
  end
end
