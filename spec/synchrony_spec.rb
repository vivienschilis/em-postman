require 'spec_helper'
require 'em-synchrony'
require 'em-synchrony/em-hiredis'
require 'em-postman/synchrony'

describe EventMachine::Postman do
  describe "when listening for messages" do

    it "should send and receive messages using em-sychrony" do
      EventMachine.synchrony do
        
        redis = EM::Hiredis::Client.connect('localhost', 6379)
        redis.flushall
        
        postman = EM::Postman.new('test', :redis => redis)
        postman.logger = Logger.new(nil)
        
        postman.send_message("test", 'cb', {:value => 'abc'})
        
        responses = []
        postman.onmessage(:cb) do |msg|
          responses << msg
        end

        postman.listen
                
        responses.should == [{"value"=>"abc"}]
        EventMachine.stop
      end
    end
    
  end
end