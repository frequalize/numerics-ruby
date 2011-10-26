require 'yajl'
require 'yaml'

require 'fz/numerics/connection'

module Fz
  module Numerics
    
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

      if !access_key && !secret_key
        raise ArgumentError, 'Fz::Numerics.connect(config_file, env=nil) or Fz::Numerics.connect(:access_key => access_key, :secret_key => :secret_key)'
      end

      Fz::Numerics::Connection.new(access_key.to_s, secret_key.to_s)
    end

  end
end
