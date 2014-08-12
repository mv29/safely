require "robustly/version"

module Robustly

  class << self
    attr_accessor :env, :report_exception_method

    def report_exception(e)
      report_exception_method.call(e)
    end
  end
  self.env = ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
  self.report_exception_method = proc do |e|
    Errbase.report(e)
  end

  module Methods

    def robustly(options = {}, &block)
      begin
        yield
      rescue => e
        raise e if %w[development test].include?(Robustly.env)
        if options[:throttle] ? rand < 1.0 / options[:throttle] : true
          Robustly.report_exception(e)
        end
      end
    end
    alias_method :yolo, :robustly

  end

end

Object.send :include, Robustly::Methods
