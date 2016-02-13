#!/bin/bash - 
export SECRET_KEY_BASE=`rake secret RAILS_ENV=production`
#echo $SECRET_KEY_BASE
bash rails s -b 0.0.0.0 -e production &
bash ruby websocket_server.rb &
