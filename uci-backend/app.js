var express = require('express')
var app = express()
var pug = require('pug')
var redis = require('redis')
var client = redis.createClient() //creates a new client

// HTML render. Pug was formerly Jade
app.set('view engine', 'pug');
app.get('/', function (req, res) {
  res.render('index');
});

/* REDIS Defaults
 hostname = 127.0.0.1
 port = 6379
*/

var client = redis.createClient()

client.on('connect', function() {
    console.log('connected to Redis DB!')
});

app.listen(1714)