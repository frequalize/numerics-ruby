require 'fz/numerics/connection'
module Fz
  module Numerics
    
    def self.connect(access_key, secret_key)
      Fz::Numerics::Connection.new(access_key, secret_key)
    end

  end
end
