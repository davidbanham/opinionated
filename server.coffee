fs = require 'fs'
http = require 'http'

index = fs.readFileSync './index.html'

app = http.createServer (req, res) ->
 res.writeHead(200, {'Content-Type': 'text/html'})
 res.end(index)

io = require('socket.io').listen app

ratings = {}
intervals = {}

io.sockets.on 'connection', (socket) ->
  socket.on 'rating', (message) ->
    ratings[message.uuid] = parseInt message.rating
    clearTimeout intervals[message.uuid] if intervals[message.uuid]
    intervals[message.uuid] = setTimeout ->
      delete ratings[message.uuid]
    , 60 * 1000

setInterval ->
  sum = 0
  for _, rating of ratings
    sum += rating
  average = sum / Object.keys(ratings).length
  io.emit 'average', average
, 1000

app.listen process.env.PORT or 3000
