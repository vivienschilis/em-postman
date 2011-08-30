require 'spec_helper'

describe EventMachine::Postman do
  describe "when listening for messages" do
    let(:redis) {
      redis = EventMachine::Hiredis.connect("redis://localhost:6379/0")
      redis.flushall
      redis
    }

    let(:postman) { 
      p = EM::Postman.new('test', :redis => redis)
      p.logger = Logger.new(nil)
      p
    }

    it "should send and recieve messages asynchronously" do
        em(1) do
          postman.send_message("test", 'cb', {:value => 'abc'})
        
          responses = []
          postman.onmessage(:cb) do |msg|
            responses << msg
          end
          postman.onmessage(:cb) do |msg|
            responses << msg
          end
          postman.listen
        
          EM.add_timer(0.2) do
            responses.should == [{"value"=>"abc"}, {"value"=>"abc"}]
            done
          end
        end
    end

    it "should unregister handlers" do 
        em(1) do
          postman.send_message("test", 'cb', {:value => 'abc'})
          responses = []
          proc = Proc.new {|msg|
            responses << msg
            postman.unlisten(:cb, proc)
          }
          postman.onmessage(:cb, &proc)

          postman.listen

          EM.add_timer(0.2) do
            postman.send_message("test", 'cb', {:value => 'cdf'})
          end

          EM.add_timer(0.4) do
            responses.should == [{"value"=>"abc"}]
            done
          end
        end
    end

    it "should gracefully handle a Redis.rpop error" do
        em(1) do
          redis.lpush("inbox_test", MultiJson.encode({:method => 'cb', :body => 'a'}))
          redis.lpush("inbox_test", "error")
          redis.lpush("inbox_test", MultiJson.encode({:method => 'cb', :body => 'b'}))

          responses = []
          postman.onmessage(:cb) do |msg|
            responses << msg
          end
          postman.listen

          EM.add_timer(0.2) do
            responses.should == ["a", "b"]
            done
          end
        end
    end

  end
end