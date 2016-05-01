#!/usr/bin/env node --harmony

// DEPENDENCIES
var express = require('express');
var session = require('cookie-session');
var favicon = require('static-favicon');
var serveStatic = require('serve-static');
var engine = require('ejs-locals');
var http = require('http');
var https = require('https');

var routes = require('./routes');
var users = require('./routes/users');
var rooms = require('./routes/rooms');
var userRooms = require('./routes/userRooms');
var account = require('./routes/account');
var roomMessages = require('./routes/roomMessages.js');
var root = require('./routes/root.js');
var auth = require('./routes/auth.js');
var http = require('http');
var path = require('path');
var util = require('util');

var app = express();

// MIDDLEWARE
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.engine('ejs', engine);
app.set('view engine', 'ejs');
app.use(favicon());
app.use(require('morgan')({ format: 'dev', immediate: true }));
app.use(require('body-parser')());
app.use(require('method-override')());

var sessionOpts = { secret: "secretsecret" };
if (process.argv.lastIndexOf("--no-session-cookies") != -1 ||
    process.argv.lastIndexOf("-n") != -1) {
  console.log("Disabling session cookies, setting maxAge to Date.now() + 1 year");
  sessionOpts.path = '/',
  sessionOpts.httpOnly = true,
  sessionOpts.maxage = 365 * 24 * 3600 * 1000;  // One year
}
app.use(session(sessionOpts));

// custom authentication middleware
app.use(auth.checkCredentials);
app.use(auth.appendLocalsToUseInViews);

// ROUTES
var router = express.Router();

// users resource
router.get('/users', users.list);
router.get('/users/new', users.newForm);
router.get('/users/:id', users.get);
router.post('/users', users.create);
router.delete('/users/:id', users.delete);

// account resource
router.get('/account/new', account.signInForm);
router.put('/account', account.signIn);
router.delete('/account', account.signOut);

// rooms resource
router.get('/rooms', rooms.list);
router.post('/rooms', rooms.create);
router.get('/rooms/new', rooms.newForm);
router.get('/rooms/:id', rooms.get);
router.delete('/rooms/:id', rooms.delete);

// rooms/users resource
router.get('/rooms/:room_id/chatters', userRooms.list);
router.put('/rooms/:room_id/chatters/:user_id', userRooms.add);
router.delete('/rooms/:room_id/chatters/:user_id', userRooms.delete);

// rooms/messages resource
router.get('/rooms/:id/messages', roomMessages.get);
router.post('/rooms/:id/messages', roomMessages.add);

// POST-ROUTE MIDDLEWARE
router.use(require('less-middleware')(path.join(__dirname, 'public')));
router.use(serveStatic(path.join(__dirname, 'public')));
router.use(require('errorhandler')());

// home page
router.get('/', root.list);

app.use(router);

// SERVER LAUNCH
if (process.argv.lastIndexOf("--https") != -1 ||
    process.argv.lastIndexOf("-s") != -1) {
  fs = require('fs');
  var sslOptions = {
    key: fs.readFileSync('./ssl/server.key'),
    cert: fs.readFileSync('./ssl/server.crt'),
  };

  https.createServer(sslOptions, app).listen(app.get('port'), function () {
    console.log("Starting HTTPS server on port " + app.get('port'));
  });
}
else {
  http.createServer(app).listen(app.get('port'), function () {
    console.log("Starting HTTP server on port " + app.get('port'));
  });
}


process.on('uncaughtException', function(err) {
  console.log('Caught exception: ' + util.inspect(err));
});
