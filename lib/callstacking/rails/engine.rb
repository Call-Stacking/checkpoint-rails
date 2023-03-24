require "rails"
require "active_support/cache"
require "callstacking/rails/env"
require "callstacking/rails/trace"
require "callstacking/rails/instrument"
require 'callstacking/rails/spans'
require "callstacking/rails/setup"
require "callstacking/rails/settings"
require "callstacking/rails/loader"
require "callstacking/rails/client/base"
require "callstacking/rails/client/authenticate"
require "callstacking/rails/client/trace"
require "callstacking/rails/cli"
require "callstacking/rails/traces_helper"
require "callstacking/rails/time_based_uuid"

module Callstacking
  module Rails
    class Engine < ::Rails::Engine
      EXCLUDED_TEST_CLASSES = ['test/dummy/app/models/salutation.rb'].freeze
      
      cattr_accessor :spans, :trace, :settings, :instrumenter, :loader

      isolate_namespace Callstacking::Rails

      @@settings||=Callstacking::Rails::Settings.new
      @@spans||=Spans.new
      @@trace||=Trace.new(@@spans)
      @@instrumenter||=Instrument.new(@@spans)

      initializer "engine_name.assets.precompile" do |app|
        app.config.assets.precompile << "checkpoint_rails_manifest.js"
      end

      initializer 'local_helper.action_controller' do
        ActiveSupport.on_load :action_controller do
          include Callstacking::Rails::TracesHelper
        end
      end

      config.after_initialize do
        if @@settings.enabled?
          puts "Call Stacking enabled (#{Callstacking::Rails::Env.environment})"

          ActionController::Base.send :after_action do
            inject_hud(@@settings)
          end

          @@loader = Callstacking::Rails::Loader.new(@@instrumenter,
                                                     excluded: @@settings.excluded + EXCLUDED_TEST_CLASSES)
          @@loader.on_load

          @@trace.request_tracing
        else
          puts "Call Stacking disabled (#{Callstacking::Rails::Env.environment})"
        end
      end

      def self.start_tracing
        return false if @@settings.disabled?

        @@instrumenter.enable!(@@loader.klasses)
        true
      end

      def self.stop_tracing
        return false if @@settings.disabled?

        @@instrumenter.disable!
        true
      end
    end
  end
end
