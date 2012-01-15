require 'yaml'

class SshAuthorizedKeys < Recipe
  desc 'ssh_authorized_keys:deploy', 'configures ssh authorized_keys'
  def deploy
    # load users and their ssh keys from yaml file
    users = YAML.load_file "#{@template_path}/users.yaml"

    authorized_keys = {}
    @config.each do |remote_user, ssh_users|
      ::Dust.print_msg "generating authorized_keys for #{remote_user}\n"
      authorized_keys = ''

      # create the authorized_keys hash for this user
      ssh_users.each do |ssh_user|
        users[ssh_user]['name'] ||= ssh_user
        ::Dust.print_msg "adding user #{users[ssh_user]['name']}", :indent => 2
        users[ssh_user]['keys'].each do |key|
          authorized_keys += "#{key}"
          authorized_keys += " #{users[ssh_user]['name']}" if users[ssh_user]['name']
          authorized_keys += " <#{users[ssh_user]['email']}>" if users[ssh_user]['email']
          authorized_keys += "\n"
        end

        ::Dust.print_ok
      end

      # create user, if not existent
      next unless @node.create_user remote_user

      # check and create necessary directories
      next unless @node.mkdir("~#{remote_user}/.ssh")

      # deploy authorized_keys
      next unless @node.write "~#{remote_user}/.ssh/authorized_keys", authorized_keys

      # check permissions
      @node.chown "#{remote_user}:#{remote_user}", "~#{remote_user}/.ssh"
      @node.chmod '0644', "~#{remote_user}/.ssh/authorized_keys"


      # TODO: add this option
      # remove authorized_keys files for all other users
      if options.cleanup?
        ::Dust.print_msg "deleting other authorized_keys files\n"
        @node.get_system_users(:quiet => true).each do |user|
          next if users.keys.include? user
          if @node.file_exists? "~#{user}/.ssh/authorized_keys", :quiet => true
            @node.rm "~#{user}/.ssh/authorized_keys", :indent => 2
           end
        end
      end

      puts
    end
  end
end
