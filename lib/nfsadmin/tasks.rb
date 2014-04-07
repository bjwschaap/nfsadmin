module Nfsadmin

	class Tasks
		def self.list_shares
			begin
				IO.popen(["/usr/sbin/exportfs -v"], ) do |io|
				  result = io.read
				end
			rescue
				puts 'Error: nfsadmin requires the exportfs command to be present.'
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