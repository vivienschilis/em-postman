require 'logger'
require 'eventmachine'
require 'em-hiredis'

require 'multi_json'
require 'yajl'
MultiJson.engine = :yajl

require 'em-postman/version'
require 'em-postman/postman'
