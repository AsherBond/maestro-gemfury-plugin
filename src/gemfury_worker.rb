require 'maestro_agent'
require 'gemfury'

module MaestroDev
  class GemfuryWorker < Maestro::MaestroWorker

    def validate_fields
      required_fields = ["account", "user_api_key", "file"]
      errors = []
      required_fields.each{|s|
        errors << "missing #{s}" if get_field(s).nil? || get_field(s).empty?
      }
      return errors
    end

    def push
      Maestro.log.info "Starting Gemfury Worker"

      errors = validate_fields
      unless errors.empty?
        msg = "Not a valid fieldset, #{errors.join("\n")}"
        Maestro.log.error msg
        set_error msg
        return
      end

      client = connect(get_field("user_api_key"), get_field("account"))

      find_gems(get_field("file")).each do |gem|
        msg = "Uploading #{gem} to Gemfury"
        Maestro.log.debug msg
        write_output "#{msg}... "

        client.push_gem(File.new(gem))

        Maestro.log.info "Uploaded #{gem} to Gemfury"
        write_output "uploaded\n"
      end

      Maestro.log.info "Completed Gemfury worker"
    end

    def connect(api_key, account)
      Gemfury::Client.new(:user_api_key => api_key, :account => account)
    end

    def find_gems(file)
      Dir.glob(file)
    end

  end
end
