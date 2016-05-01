#!/usr/bin/env node --harmony

/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var video = require('./routes/video');
var http = require('http');
var path = require('path');
var fs = require('fs');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/videos', video.list);
app.post('/videos', video.add);
app.get('/videos/:video_id', video.get);
app.delete('/videos/:video_id', video.delete);
app.put('/videos/:video_id/movie', video.uploadMovie);

// make sure we have a 'public/videos' directory
var videosDir = path.join(__dirname, 'public/videos');
if (! fs.existsSync(videosDir)) {
  fs.mkdirSync(videosDir, 0755);
};

var server = http.createServer(app);
var util = require('util');
server.setTimeout(5 * 60 * 1000, function() {
  console.log("TIMEOUT args: " + util.inspect(arguments));
});
server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
