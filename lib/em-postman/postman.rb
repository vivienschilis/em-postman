module EventMachine
  class Postman
      attr_accessor :mailbox
      attr_writer :logger

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def handlers
        @handlers ||= {}
      end

      def initialize(mailbox, options = {})
        @mailbox = mailbox
        @timeout = options[:timeout] || 5
        @redis_options = {:db => 0, :host => 'localhost', :port => 6379}

        @options = options
        if options[:redis].is_a?(EventMachine::Hiredis::Client)
          @redis = options[:redis]
          @redis_options = extract_redis_options(@redis)
        else
          @redis_options.merge(options[:redis] || {})
        end
      end

      def redis
        @redis ||= new_redis_client
      end

      def clear
        redis.del(inbox_name)
      end

      def onmessage(method, &callback)
        debug "##{method} registered"

        handlers[method.to_s] ||= []
        handlers[method.to_s] << callback
      end

      def unlisten(method, callback)
        if cbs = handlers[method.to_s]
          cbs.delete(callback)
        end
      end
      
      def send_message(recipient, method, body)
        message = MultiJson.encode({
          'method' => method,
          'body' => body
        })

        debug "-> #{recipient}##{method}: #{body.inspect}"
        redis.lpush("postman:inbox_#{recipient}", message)
      end

      def listen
        listen_messages
      end

      private

      def new_redis_client
        new_redis_client = EventMachine::Hiredis::Client.connect(@redis_options[:host], @redis_options[:port])
        new_redis_client.select(@redis_options[:db])
        new_redis_client
      end

      def extract_redis_options(redis)
        {
          :host => redis.host,
          :port => redis.port,
          :db => redis.db
        }
      end

      def inbox_name
        "postman:inbox_#{@mailbox}"
      end

      def debug(message)
        logger.debug "Postman[#{mailbox}]: #{message}"
      end

      def listen_messages(redis = new_redis_client)
        EM.next_tick do
          deferable = redis.brpop(inbox_name, @timeout)
          deferable.callback do |channel, message|
            handle_rpop(channel, message)
            listen_messages(redis)
          end

          deferable.errback do |error|
            logger.error "Postman[#{mailbox}]: #{error.inspect}"
            listen_messages(redis)
          end
        end
      end

      def handle_rpop(channel, message)
        begin
          if channel.nil? # due to timeout
          else
            debug "<- #{message}"
            data = MultiJson.decode(message)
            if (callbacks = handlers[data['method'].to_s]) && !callbacks.empty?
              callbacks.each {|cb| cb.call(data['body'])}
            else
              logger.warn "Postman[#{mailbox}]: no handler found for #{data['method']}"
            end
          end
        rescue MultiJson::DecodeError => error
          logger.error "Postman[#{mailbox}]: unable to parse message #{message}"
        rescue  => error
          logger.error "Postman[#{mailbox}]: #{error}"
        end
      end
  end
end
