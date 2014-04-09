require 'json'

module Nfsadmin

  class Tasks
    def self.get_shares(exportsfile)
      shares = []
      location = ''
      begin
        file = File.open(exportsfile, 'r')
      rescue
        fail 'No exports configuration could be found'
      end
      file.readlines.each do |line|
        share = {}
        acl = []
        parts = line.split
        parts.each do |part|
          entry = {}
          if (Pathname.new(part)).absolute?
            location = part
          else
            subparts = part.split('(')
            entry[:address] = subparts[0]
            entry[:options] = subparts[1].sub!(/\)/, '')
            acl << entry
          end
        end
        share[:location] = location
        share[:acl] = acl
        shares << share
      end
      file.close
      return shares
    end

    def self.write_exports(exportsfile, exports)
      begin
        file = File.open(exportsfile, File::WRONLY|File::CREAT)
        file.truncate(0)
      rescue
        fail "Could not write to exports configuration #{exportsfile}"
      end
      exports.each do |share|
        file.print(share[:location] + '   ')
        share[:acl].each do |acl|
          file.print acl[:address].to_s + '(' + acl[:options].to_s + ')' + ' '
        end
        file.print "\n"
      end
      file.flush
      file.close
    end

    def self.list_shares(exportsfile, output_type)
      exports = get_shares(exportsfile)
      if output_type == 'text'
        # Output plain text
        exports.each do |share|
          printf('%-40s', share[:location])
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

    def self.create_share(exportsfile, location, address, options)
      if location.nil?
        fail 'Location must be specified'
      end
      if address.nil?
        fail 'Address must be specified'
      end
      if options.nil?
        fail 'Options must be specified'
      end
      share = { :location => location,
                :acl => [{
                    :address => address,
                    :options => options
                }]
      }
      shares = get_shares(exportsfile)
      existingshare = shares.find { |s| s[:location] == location }
      if existingshare.nil?
        shares << share
        write_exports(exportsfile, shares)
      else
        puts 'Share already exists. Use nfsadmin export modify to change it. Skipping'
      end
    end

    def self.delete_share(exportsfile, location)
      if location.nil?
        fail 'Location must be specified with -l or --location='
      end
      shares = get_shares(exportsfile)
      share = shares.find { |share| share[:location] == location }
      shares.delete(share)
      write_exports(exportsfile, shares)
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
