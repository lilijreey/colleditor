# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
$(document).ready ()->
    console.log 'doc ready'
    conn = {'isJoin':false}
    editor = ace.edit("editor")
    editor.setTheme("ace/theme/chrome")
    editor.getSession().setMode("ace/mode/c_cpp")

    editor_onchange=(e) ->
        if (conn.isJoin)
            console.log('onchange')
            if (editor.curOp && editor.curOp.command.name)
                ##change by user
                console.log('send' + editor.curOp.command.name)
                conn.ws.send(editor.getValue())
            else #change by api
                console.log('onchange by api')


    # font-size change
    editor.setFontSize('20px')
    $("#font-size").val(20)
    $("#font-size").change ()->
        console.log("font-size change" + $(this).val())
        editor.setFontSize($(this).val() + 'px')

    # connect/disconect server
    join_trigger = () ->
        console.log "join_trigger"
        btn = $("button#join")
        conn.isJoin = !btn.data('isJoin')
        if (conn.isJoin)
            btn.html("断开连接")
        else
            btn.html("连接服务器")
        btn.data('isJoin', conn.isJoin)
        btn.attr('disabled', false)

    $('button#join').click ->
        #TODO 1秒钟锁定button,方式连续点击
        $(this).attr('disabled', true)
        isJoin = $(this).data('isJoin')
        console.log("join:" + isJoin)
        if (isJoin)
            conn.ws.close()
        else
            ip = $(this).data('ip')
            url = encodeURI("ws://" + ip + ":5567?nick" + $('#nick').val())
            conn.ws= new WebSocket(url)
            ws_cb(conn.ws)

    $('button#readonly').click ->
        isReadOnly = $(this).data('isReadonly')
        console.log("readonly click:" + isReadOnly)
        if isReadOnly
            $(this).removeClass('btn-primary')
        else
            $(this).addClass('btn-primary')
        editor.setReadOnly(!isReadOnly)
        $(this).data('isReadonly', !isReadOnly)

    # webSocket cb
    ws_cb=(ws) ->
        ws.onopen = ()->
            console.log("onopen")
            join_trigger()
            editor.getSession().on('change', editor_onchange)
            
        ws.onclose = (evt)->
            console.log("onclose" + evt.code)
            join_trigger()

        ws.onerror = (evt) ->
            alert("webSocket error:" + evt.data)

        ws.onmessage = (evt) ->
            editor.setValue(evt.data)






    
