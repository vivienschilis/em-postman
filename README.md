Getting started
===============

Postman is an EventMachine Pub/Sub resilient to failure.
Postman uses Redis lists (brpop and lpush) to send messages to subscribers into a mailbox.

Postman has been designed to be resilient to failure on both side: publisher and subscriber. 
If your postman process dies or need to be restarted, it will be able to collect again messages from its mailbox.


Example
=======

Server postbox: (server.rb)

``` ruby
require 'em-postman'

EM.run {
  postman = EM::Postman.new('server')

  postman.onmessage(:greetings) {|data|
    puts data.inspect
    postman.send_message data['from'], :greetings, {:message => 'hello ' + data['from']}
  }

  postman.listen
}
```

Client postbox: (client.rb)

``` ruby
require 'em-postman'

EM.run {

  postman = EM::Postman.new('client-' + Process.pid.to_s)
  postman.onmessage(:greetings) {|data|
    puts data.inspect
    EM.stop
  }

  postman.send_message 'server', :greetings, {:message => 'hello server', :from => postman.mailbox}
  postman.listen
}
```

Credits
=======

- This gem has been extracted from http://pandastream.com.
- Thanks to Jonas Pfenniger(zimbatm) and Martyn Loughran(mloughran)
