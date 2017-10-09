require 'etc'
require 'fileutils'
require 'json'
require 'pathname'

module Nfsadmin

  class Tasks

    @service_cmd = ''

    begin
      file = File.new('/usr/sbin/service')
      @service_cmd = '/usr/sbin/service'
    rescue
      file = File.new('/sbin/service')
      @service_cmd = '/sbin/service'
    end


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
        stat = File.stat(location)
        share[:location] = location
        share[:owner] = Etc.getpwuid(stat.uid).name
        share[:group] = Etc.getgrgid(stat.gid).name
        share[:mode] = stat.mode.to_s(8)[-3,3]
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
      if output_type.downcase == 'text'
        # Output plain text
        exports.each do |share|
          printf('%-40s', share[:location])
          share[:acl].each do |acl|
            print acl[:address] + '(' + acl[:options] + ')' + ' '
          end
          print(share[:owner]) unless share[:owner].nil?
          print(':' + share[:group] + ' ') unless share[:group].nil?
          print(share[:mode] + "\n")
        end
        STDOUT.flush
      elsif output_type.downcase == 'json'
        # Output JSON
        puts JSON.generate({ :exports => exports })
      else
        fail "#{output_type} is an invalid output format. Must one of: text, json"
      end
    end

    def self.create_share(exportsfile, location, address, options, createlocation, user, group, mode)
      if location.nil?
        fail 'Location must be specified'
      else
        fail 'Location must be an absolute path' unless (Pathname.new(location)).absolute?
      end
      if address.nil?
        fail 'Address must be specified'
      end
      if options.nil?
        fail 'Options must be specified'
      end
      if createlocation
        FileUtils::mkdir_p location unless File.directory?(location)
        FileUtils::chown user, nil, location unless user.nil?
        FileUtils::chown nil, group, location unless group.nil?
        FileUtils::chmod mode, location unless mode.nil?
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
        puts 'Share created'
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
      if share.nil?
        fail "#{location} not found"
      else
        shares.delete(share)
        write_exports(exportsfile, shares)
        puts "Deleted #{location}"
      end
    end

    def self.get_share(exportsfile, location)
      if location.nil?
        fail 'Location must be specified with -l or --location='
      end
      shares = get_shares(exportsfile)
      shares.find { |share| share[:location] == location }
    end

    def self.print_share(exportsfile, location, output_type)
      share = get_share(exportsfile, location)
      if share.nil?
        fail 'share not found'
      end
      if output_type.downcase == 'text'
        printf('%-40s', share[:location])
        share[:acl].each do |acl|
          print acl[:address] + '(' + acl[:options] + ')' + ' '
        end
        print "\n"
        STDOUT.flush
      elsif output_type.downcase == 'json'
        puts JSON.generate(share)
      else
        fail "#{output_type} is an invalid output format. Must one of: text, json"
      end
    end

    def self.show_status
      system "#{@service_cmd} nfs status"
    end

    def self.start_service
      system "#{@service_cmd} nfs start"
    end

    def self.stop_service
      system "#{@service_cmd} nfs stop"
    end

    def self.restart_service
      system "#{@service_cmd} nfs restart"
    end

    def self.reload_config
      system "#{@service_cmd} nfs reload"
    end
  end

end
