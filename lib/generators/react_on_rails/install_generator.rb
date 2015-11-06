# Install Generator: gem's only public generator
#
# Usage:
#   rails generate react_on_rails:install [options]
#
# Options:
#   [--redux], [--no-redux]
#     Indicates when to generate with redux
#   [--server-rendering], [--no-server-rendering]
#     Indicates whether ability for server-side rendering of webpack output should be enabled
#   [--skip-js-linters]
#     Do no install JavaScript linter files and configs
#   [--ruby-linters]
#     Install ruby linter files, tasks, and configs
#
require "rails/generators"

module ReactOnRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      # --redux
      class_option :redux,
                   type: :boolean,
                   default: false,
                   desc: "Setup Redux files",
                   aliases: "-R"
      # --server-rendering
      class_option :server_rendering,
                   type: :boolean,
                   default: false,
                   desc: "Configure for server-side rendering of webpack JavaScript",
                   aliases: "-S"
      # --skip-js-linters
      class_option :skip_js_linters,
                   type: :boolean,
                   default: false,
                   desc: "Skip installing JavaScript linting files",
                   aliases: "-j"
      # --ruby-linters
      class_option :ruby_linters,
                   type: :boolean,
                   default: false,
                   desc: "Install ruby linting files, tasks, and configs",
                   aliases: "-L"

      def run_generators
        return unless installation_prerequisites_met?
        warn_if_nvm_is_not_installed
        invoke "react_on_rails:base"
        invoke "react_on_rails:react_no_redux" unless options.redux?
        invoke "react_on_rails:react_with_redux" if options.redux?
        invoke "react_on_rails:js_linters" unless options.skip_js_linters?
        invoke "react_on_rails:ruby_linters" if options.ruby_linters?
        invoke "react_on_rails:bootstrap"
        invoke "react_on_rails:heroku_deployment"
      end

      private

      # NOTE: other requirements for existing files such as .gitignore or application.
      # js(.coffee) are not checked by this method, but instead produce warning messages
      # and allow the build to continue
      def installation_prerequisites_met?
        !(missing_node? || missing_npm? || uncommitted_changes?)
      end

      def missing_npm?
        return false unless `which npm`.blank?
        error = "** npm is required. Please install it before continuing."
        error << "https://www.npmjs.com/"
        puts error
      end

      def missing_node?
        return false unless `which node`.blank?
        error = "** nodejs is required. Please install it before continuing."
        error << "https://nodejs.org/en/"
        puts error
      end

      def uncommitted_changes?
        return false if ENV["COVERAGE"]
        status = `git status`
        return false if status.include?("nothing to commit, working directory clean")
        error = "** You have uncommitted code. Please commit or stash your changes before continuing"
        puts error
      end

      def warn_if_nvm_is_not_installed
        return true unless `which nvm`.blank?
        puts "** nvm is advised. Please consider installing it. https://github.com/creationix/nvm"
      end
    end
  end
end
