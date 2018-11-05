#!/bin/bash - 
#export SECRET_KEY_BASE=`rake secret RAILS_ENV=production`
#echo $SECRET_KEY_BASE
rails s -b 0.0.0.0  -d
ruby websocket_server.rb &
