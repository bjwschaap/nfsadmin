require 'gli'
require 'json'

module Nfsadmin

  class Tasks
    def self.get_shares
      shares = []
      mountpoint = ''
      begin
        file = File.open('/etc/exports', 'r')
      rescue
        raise GLI::CustomExit.new('No exports configuration could be found',-2)
      end
      file.readlines.each do |line|
        share = {}
        acl = []
        parts = line.split
        parts.each do |part|
          entry = {}
          if (Pathname.new(part)).absolute?
            mountpoint = part
          else
            subparts = part.split('(')
            entry[:address] = subparts[0]
            entry[:options] = subparts[1].sub!(/\)/, '')
            acl << entry
          end
        end
        share[:mountpoint] = mountpoint
        share[:acl] = acl
        shares << share
      end
      file.close
      return shares
    end

    def self.list_shares(output_type)
      exports = get_shares
      if output_type == 'text'
        # Output plain text
        exports.each do |share|
          printf('%-40s', share[:mountpoint])
          share[:acl].each do |acl|
            print acl[:address] + '(' + acl[:options] + ')' + ' '
          end
          print "\n"
        end
        STDOUT.flush
      else
        # Output JSON
        puts JSON.generate({ :exports => exports })
      end
    end

    def self.create_share
      puts 'Create a new NFS share'
    end

    def self.delete_share
      puts 'Delete a NFS share'
    end

    def self.show_status
      `/usr/sbin/service nfs status`
    end

    def self.start_service
      `/usr/sbin/service nfs start`
    end

    def self.stop_service
      `/usr/sbin/service nfs stop`
    end

    def self.restart_service
      `/usr/sbin/service nfd restart`
    end

    def self.reload_config
      `/usr/sbin/service nfs reload`
    end
  end

end
