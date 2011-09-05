module EventMachine
  class Postman
    def listen_messages(redis = new_redis_client)
      channel, message = redis.brpop(inbox_name, @timeout)

      handle_rpop(channel, message) if channel && message

      EM.next_tick do
        Fiber.new { 
          listen_messages(redis)
        }.resume
      end
    end
  end
end