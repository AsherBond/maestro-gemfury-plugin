require 'maestro_plugin'
require 'gemfury'

module MaestroDev
  module Plugin
    class GemfuryWorker < Maestro::MaestroWorker

      def push
        validate_parameters

        client = connect

        find_gems.each do |gem|
          write_output("\nUploading #{gem} to Gemfury...", :buffer => true)
          client.push_gem(File.new(gem))
          write_output "complete"
        end
      end

      ###########
      # PRIVATE #
      ###########

      def connect
        Gemfury::Client.new(:user_api_key => @user_api_key, :account => @account)
      end

      def find_gems
        Dir.glob(@file).sort
      end

      def validate_parameters
        errors = []

        @account = get_field('account', '')
        @user_api_key = get_field('user_api_key', '')
        @file = get_field('file', '')

        errors << 'missing field account' if @account.empty?
        errors << 'missing field user_api_key' if @user_api_key.empty?
        errors << 'missing field file' if @file.empty?

        raise ConfigError, "Config Errors: #{errors.join(', ')}" unless errors.empty?
      end

    end
  end
end
