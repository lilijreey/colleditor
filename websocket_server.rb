
require 'em-websocket'

module Editor
  module WSServer
    class EM::WebSocket::Connection
      attr_accessor :sid
      attr_accessor :room_id
    end

    def WSServer.stop
      puts "Terminating WebSocket Server"
      EventMachine.stop
    end

    trap("INT") { stop }
    trap("TERM") { stop }

    EM.epoll
    EM.run do

      @rooms = {}
      @rooms_code = {}
      puts "new Channel" 

      EM::WebSocket.run(host: "0.0.0.0", port: 5567) do |ws|
        ## 每个新的连接都会执行这个block

        ## 里面的都是回调
        ws.onopen do  |handshake|
          puts "new connect"
          #ws.methods
          #puts handshake.public_methods
          ws.room_id= handshake.query['room_id']
          room = @rooms[ws.room_id] ||=  EM::Channel.new

          ws.sid = room.subscribe { |sid| 
            #puts "sid:#{ws.sid} #{sid}" 
            ws.send(@rooms_code[ws.room_id]) if sid !=ws.sid 
          }

          ws.send(@rooms_code[ws.room_id]) if @rooms_code.has_key?(ws.room_id) # init src
        end

        ws.onmessage do |msg|
          @rooms_code[ws.room_id] = msg
          @rooms[ws.room_id].push(ws.sid)
        end

        ws.onclose do
          @rooms[ws.room_id].unsubscribe(ws.sid)
          if @rooms[ws.room_id].num_subscribers == 0
            @rooms.delete(ws.room_id)
            @rooms_code.delete(ws.room_id)
            puts "delete room #{room_id}"
          end

          puts "on close"
        end
      end
    end

  end
end
