# frozen_string_literal: true

require "English"
require "open3"
require "rainbow"
require "active_support"

module ReactOnRails
  module Utils
    # https://forum.shakacode.com/t/yak-of-the-week-ruby-2-4-pathname-empty-changed-to-look-at-file-size/901
    # return object if truthy, else return nil
    def self.truthy_presence(obj)
      if obj.nil? || obj == false
        nil
      else
        obj
      end
    end

    def self.object_to_boolean(value)
      [true, "true", "yes", 1, "1", "t"].include?(value.class == String ? value.downcase : value)
    end

    def self.server_rendering_is_enabled?
      ReactOnRails.configuration.server_bundle_js_file.present?
    end

    # Invokes command, exiting with a detailed message if there's a failure.
    def self.invoke_and_exit_if_failed(cmd, failure_message)
      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success?
        msg = <<~MSG.strip_heredoc
          #{'Z' * 80}
                    React on Rails FATAL ERROR!
                    #{failure_message}
                    cmd: #{cmd}"
                    stdout: #{stdout.strip}
                    stderr: #{stderr.strip}
                    exitstatus: #{status.exitstatus}
                  #{'Z' * 80}
        MSG
        puts Rainbow(msg).red
        exit(1)
      end
      [stdout, stderr, status]
    end

    def self.server_bundle_js_file_path
      bundle_js_file_path(ReactOnRails.configuration.server_bundle_js_file)
    end

    # TODO: conturbo Write Test for this, with BOTH webpacker_lite installed and not, and
    # with case for webpacker_lite, but server file is not in the file
    def self.bundle_js_file_path(bundle_name)
      # For testing outside of Rails app

      if using_webpacker_lite? && WebpackerLite::Manifest.lookup(bundle_name)
        # If using webpacker_lite gem
        public_subdir_hashed_file_name = ActionController::Base.helpers.asset_pack_path(bundle_name)
        return File.join("public", public_subdir_hashed_file_name)
      end

      File.join(ReactOnRails.configuration.generated_assets_dir, bundle_name)
    end

    def self.using_webpacker_lite?
      ActionController::Base.helpers.respond_to?(:asset_pack_path)
    end

    def self.running_on_windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.rails_version_less_than(version)
      @rails_version_less_than ||= {}

      if @rails_version_less_than.key?(version)
        return @rails_version_less_than[version]
      end

      @rails_version_less_than[version] = begin
        Gem::Version.new(Rails.version) < Gem::Version.new(version)
      end
    end

    def self.rails_version_less_than_4_1_1
      rails_version_less_than("4.1.1")
    end

    module Required
      def required(arg_name)
        raise ArgumentError, "#{arg_name} is required"
      end
    end
  end
end
