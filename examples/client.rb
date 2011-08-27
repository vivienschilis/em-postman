require 'em-postman'

EM.run {

  postbox = EM::Postman.new('client-' + Process.pid.to_s )
  postbox.onmessage(:greetings) {|data|
    puts data.inspect
    EM.stop
  }

  100.times {|i|
    postbox.send_message('server', :greetings, {:message => "hello server, message #{i} ", :from => postbox.mailbox})
  }

  postbox.listen
}
