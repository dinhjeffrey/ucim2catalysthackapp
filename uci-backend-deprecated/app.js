var express = require('express')
var app = express()
var pug = require('pug')
var redis = require('redis')
var client = redis.createClient() //creates a new client
var GitHubStrategy = require('passport-github').Strategy;
var passport = require('passport')
var session = require('express-session');
var RedisStore = require('connect-redis')(session);
 

 /* Problems
 User isnt defined. I think it has to do with a database schema issue
 */


// passport
// Github Oauth Strategy
const GITHUB_CLIENT_ID = '972b25ea91328fb318a7'
const GITHUB_CLIENT_SECRET = '01a687d4649f9871ec45ce5cf4be57c55c7478fe'
passport.use(new GitHubStrategy({
    clientID: GITHUB_CLIENT_ID,
    clientSecret: GITHUB_CLIENT_SECRET,
    callbackURL: "http://127.0.0.1:1714/auth/github/callback"
  },
  function(accessToken, refreshToken, profile, cb) {
  	console.log('in passport.use, function()')
    User.findOrCreate({ githubId: profile.id }, function (err, user) {
      return cb(err, user);
    });
  }
));
// passport session
passport.serializeUser(function(user, done) {
  console.log('in passport.serializeUser')
  done(null, user.id);
});
passport.deserializeUser(function(id, done) {
  User.findById(id, function (err, user) {
  	console.log('in passport.deserializeUser')
    done(err, user);
  });
});

// ROUTES
// HTML render. Pug was formerly Jade
app.set('view engine', 'pug');
app.get('/', function (req, res) {
  res.render('index');
});
// github Oauth route
app.get('/auth/github',
  passport.authenticate('github'));

app.get('/auth/github/callback', 
  passport.authenticate('github', { failureRedirect: '/login' }),
  function(req, res) {
    // Successful authentication, redirect home.
    res.redirect('/');
  });

/* DATABASE
 Redis 
 hostname = 127.0.0.1
 port = 6379
*/
var client = redis.createClient()
client.on('connect', function() {
    console.log('connected to Redis DB!')
});
 // redis session store for connect
app.use(session({
    store: new RedisStore({
    	host: '127.0.0.1',
    	port: '6379'
    }),
    secret: 'keyboard cat'
}));
// lost redis connection
app.use(session( /* setup session here */ ))
app.use(function (req, res, next) {
  if (!req.session) {
    return next(new Error('oh no')) // handle error 
  }
  next() // otherwise continue 
})


console.log('listening on port 1714')
app.listen(1714)