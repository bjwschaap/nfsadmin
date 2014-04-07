module Nfsadmin

	class Tasks
		def self.list_shares
			IO.popen(["/usr/sbin/exportfs", "-v"], :err=>[:child, :out]) do |io|
			  output = io.read
			  puts output
			end
		end

		def self.create_share
			puts 'Create a new NFS share'
		end

		def self.delete_share
			puts 'Delete a NFS share'
		end

		def self.show_status
			puts 'Show the status of the NFS service(s)'
		end

		def self.start_service
			puts 'Start the NFS service(s)'
		end

		def self.stop_service
			puts 'Stop the NFS service(s)'
		end

		def self.restart_service
			puts 'Restart the NFS service(s)'
		end

		def self.reload_config
			puts 'Reload the exported NFS shares'
		end
	end

end