require 'yaml'
if RUBY_VERSION =~ /^1\.8/
  require 'rubygems'
end
require 'yajl'

require 'numerics/connection'

module Numerics

  VERSION = '0.2.4'
  
  def self.connect(arg, env=nil)
    config = if arg.is_a?(Hash)
               arg
             else
               if arg.match(/\.json$/)
                 File.open(arg){ |f| Yajl::Parser.parse(f) }
               elsif arg.match(/\.ya?ml$/)
                 YAML::load_file(arg)
               else
                 nil
               end
             end

    if !config
      raise "Only json and yaml config files supported"
    end
    
    if env
      config = config[env.to_s] || config[env.to_sym]
      if !config
        raise "No #{env} found in #{arg}"
      end
    end

    access_key = config[:access_key] || config['access_key']
    secret_key = config[:secret_key] || config['secret_key']
    host = config[:host] || config['host'] # nil means use the default
    port = config[:port] || config['port'] # nil means use the default
    disabled = config[:disabled] || config['disabled']

    if !access_key && !secret_key
      raise ArgumentError, 'Numerics.connect(config_file, env=nil) or Numerics.connect(:access_key => access_key, :secret_key => :secret_key)'
    end

    Numerics::Connection.new(access_key, secret_key, host, port, disabled)
  end

  def self.config(arg, env=nil)
    @global_connection = self.connect(arg, env)
  end

  def self.global_connection
    @global_connection
  end

  def self.global_connection=(gc)
    @global_connection = gc
  end

  def self.respond_to?(method)
    !@global_connection.nil? && @global_connection.respond_to?(method)
  end

  ##@@ check syntax
  def self.method_missing(method, *args, &block)
    if self.respond_to?(method)
      @global_connection.send(method, *args, &block)
    else
      super
    end

  end

end

