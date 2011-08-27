require 'em-postman'

EM.run {
  postman = EM::Postman.new('server')

  postman.onmessage(:greetings) {|data|
    puts data.inspect
    postman.send_message(data['from'], :greetings, {:message => 'hello ' + data['from']})
  }

  postman.listen
}
