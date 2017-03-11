
require 'em-websocket'

module Editor
  module WSServer
    class EM::WebSocket::Connection
      attr_accessor :sid
    end

    def WSServer.stop
      puts "Terminating WebSocket Server"
      EventMachine.stop
    end

    trap("INT") { stop }
    trap("TERM") { stop }

    EM.epoll
    EM.run do


      channle = EM::Channel.new
      @src
      puts "new Channel"

      EM::WebSocket.run(host: "0.0.0.0", port: 5567) do |ws|
        ## 每个新的连接都会执行这个block

        ## 里面的都是回调
        ws.onopen do  |handshake|
          puts "new connect"
          #ws.methods
          #puts handshake.public_methods
          #nick = handshake.query['nick'] || "匿名"

          ws.sid = channle.subscribe { |sid| 
            #puts "sid:#{ws.sid} #{sid} send:#{msg} "
            ws.send(@src) if sid !=ws.sid 
          }

          ws.send(@src) unless @src.nil? # init src
        end

        ws.onmessage do |msg|
          @src = msg
          channle.push(ws.sid)
        end

        ws.onclose do
          channle.unsubscribe(ws.sid)
          #puts "on close"
        end
      end
    end

  end
end
