
require 'em-websocket'

module Editor
  module WSServer
    class Connection < EM::WebSocket::Connection
      attr_accessor :sid
    end

    EM.epoll
    EM.run do
      trap("INT") { stop}
      trap("TERM") { stop}

      def stop
        puts "Terminating WebSocket Server"
        EventMachine.stop
      end

      channle = EM::Channel.new
      puts "new Channel"

      EM::WebSocket.run(host: "0.0.0.0", port: 5567, handler:Connection) do |ws|
        ## 每个新的连接都会执行这个block

        ## 里面的都是回调
        ws.onopen do  |handshake|
          puts "new connect"
          #ws.methods
          #puts handshake.public_methods
          #nick = handshake.query['nick'] || "匿名"

          ws.sid = channle.subscribe { |data| 
            sid, msg = data
            #puts "sid:#{ws.sid} #{sid} send:#{msg} "
            ws.send(msg) if sid !=ws.sid 
          }
        end

        ws.onmessage do |msg|
          channle.push([ws.sid, msg])
        end

        ws.onclose do
          channle.unsubscribe(ws.sid)
          #puts "on close"
        end
      end
    end

  end
end
