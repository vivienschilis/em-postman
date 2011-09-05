module EventMachine
  class Postman
    def listen_messages(redis = new_redis_client)
      channel, message = redis.brpop(inbox_name, @timeout)
      
      handle_rpop(channel, message) if channel && message

      EM::Synchrony::add_timer(0) {
        listen_messages(redis)
      }
    end
  end
end