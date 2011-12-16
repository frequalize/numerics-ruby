require 'net/https'
require 'cgi'
if RUBY_VERSION =~ /^1\.8/
  require 'rubygems'
end
require 'yajl'

module Numerics
  class Connection

    HOST = 'api.numerics.io'
    PORT = '443'
    BASE_PATH = '/ts'

    attr_reader :access_key, :secret_key, :host, :port

    def initialize(access_key, secret_key, host=nil, port=nil, disabled=nil)
      @access_key, @secret_key = access_key.to_s, secret_key.to_s
      @host = (host || HOST).to_s
      @port = (port || PORT).to_s
      @disabled = !!disabled
    end

    def to_s
      "#<Numerics::Connection @access_key=#{@access_key}>"
    end

    def disable!
      @disabled = true
    end

    def enable!
      @disabled = false
    end

    def enabled?
      !@disabled
    end

    def disabled?
      @disabled
    end

    ## Start Commands ##

    def list
      self.coll_get
    end

    def create(name, precision=nil)
      self.coll_post([name, precision.to_s])
    end

    def about(timeseries)
      self.get(timeseries, 'about')
    end

    def describe(timeseries, md)
      self.put(timeseries, 'describe', md)
    end

    def erase(timeseries)
      self.destroy(timeseries)
    end

    ##@@ todo - support time words
    def insert(timeseries, number='1', time=Time.now, properties={})
      self.post(timeseries, 'insert', [time.to_s, number.to_s, properties])
    end

    ##@@ todo - support time words
    def remove(timeseries, number='1', time=Time.now, properties={})
      self.post(timeseries, 'remove', [time.to_s, number.to_s, properties])
    end

    def entries(timeseries, query=nil)
      self.get(timeseries, 'entries', query)
    end

    def series(timeseries, query=nil)
      self.get(timeseries, 'series', query)
    end

    def stats(timeseries)
      self.get(timeseries, 'stats')
    end

    def stats_per(timeseries, property_name)
      self.get(timeseries, 'stats_per', :p => property_name)
    end

    def stats_without_zeros(timeseries)
      self.get(timeseries, 'stats_without_zeros')
    end

    def tally_of(timeseries, val)
      self.get(timeseries, 'tally_of', :v => val)
    end

    def distribution(timeseries, width=nil, start=nil)
      query =  if width || start
                 {:w => width, :s => start}
               else
                 nil
               end
      self.get(timeseries, 'distribution', query)
    end

    def properties(timeseries)
      self.get(timeseries, 'properties')
    end

    def version(timeseries)
      self.get(timeseries, 'version')
    end

    def draw(timeseries, query=nil)
      self.get(timeseries, 'draw', query)
    end

    def histogram(timeseries, width=nil, start=nil)
      query =  if width || start
                 {:w => width, :s => start}
               else
                 nil
               end
      self.get(timeseries, 'histogram', query)
    end

    def headline(timeseries, query=nil)
      self.get(timeseries, 'headline', query)
    end

    def trend(timeseries, query=nil)
      self.get(timeseries, 'trend', query)
    end

    ## End Commands

    protected

    def client
      if !@client
        @client = Net::HTTP.new(@host, @port)
        @client.use_ssl = true
        @client.verify_mode = OpenSSL::SSL::VERIFY_NONE ##@@remove me after alpha!         
      end
      @client
    end

    def get(timeseries, command, query=nil)
      path = [BASE_PATH, [*timeseries], command].flatten.join('/')
      if query
        path << '?'
        parts = []
        query.keys.each do |k|
          parts << [CGI::escape(k.to_s), CGI::escape(query[k].to_s)].join('=')
        end
        path << parts.join('&')
      end
      self.do_request Net::HTTP::Get.new(path)
    end

    def post(timeseries, command, args)
      path = [BASE_PATH, [*timeseries], command].flatten.join('/')
      req = Net::HTTP::Post.new(path)
      req.body = Yajl::Encoder.encode(args)
      self.do_request req
    end

    def put(timeseries, command, args)
      path = [BASE_PATH, [*timeseries], command].flatten.join('/')
      req = Net::HTTP::Put.new(path)
      req.body = Yajl::Encoder.encode(args)
      self.do_request req
    end

    def destroy(timeseries)
      path = [BASE_PATH, [*timeseries]].flatten.join('/')
      self.do_request Net::HTTP::Delete.new(path)
    end

    def coll_get
      self.do_request Net::HTTP::Get.new(BASE_PATH)
    end

    def coll_post(args)
      req = Net::HTTP::Post.new(BASE_PATH)
      req.body = Yajl::Encoder.encode(args)
      self.do_request req
    end

    def do_request(req)
      if self.enabled?
        req['X-Access-Key'] = @access_key
        req['X-Secret-Key'] = @secret_key
        req['Content-Type'] = 'application/json'
        response = self.client.start do |h|
          h.request(req)
        end
        data = Yajl::Parser.parse(response.body)
        if data[0]
          {:error => data[0]}
        else
          {:success => true, :data => data[1]}
        end
      else
        {:disabled => true}
      end
    end

  end
end

