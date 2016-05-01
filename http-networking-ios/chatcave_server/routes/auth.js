var util = require('util');
var express = require('express');
var usersDB = require ('../data/usersDB.js');

function canRequestBeUnauthenticated(req) {
  // Requests for these resources/verbs don't require
  // the user to be authenticated
  return req.path === '/' ||
    req.path.match(/\/(stylesheets|javascripts|images)\/*/) ||
    req.path === '/account/new' ||
    (req.path === '/account' && req.method === 'PUT') ||
    req.path === '/users/new' ||
    (req.path === '/users' && req.method === 'POST');
};

function doesRequestHaveUserInSession(req) {
  if (req.session) {
    return req.session.hasOwnProperty('user_id');
  }

  return false;
};

function checkForAuthorization(req, res, next) {
  if (req.get('authorization')) {
    var header=req.get('authorization')||'',        // get the header
        token=header.split(/\s+/).pop()||'',            // and the encoded auth token
        auth=new Buffer(token, 'base64').toString(),    // convert from base64
        parts=auth.split(/:/),                          // split on colon
        username=parts[0],
        password=parts[1];

    usersDB.authenticateUser(username, password, function(err, user) {
      if (user !== null) {
        req.session['user_id'] = user.id;
        next();
      }
      else {
        handleUnauthenticatedResponse(res);
      }
    });
  }
  else if (req.get('x-magic-auth')) {
    var apiKey = req.get('x-magic-auth');
    usersDB.authenticateUserByKey(apiKey, function(err, user) {
      if (user !== null) {
        req.session['user_id'] = user.id;
        next();
      }
      else {
        handleUnauthenticatedResponse(res);
      }
    });
  }
  else {
    handleUnauthenticatedResponse(res);
  }
};

function handleUnauthenticatedResponse(res) {
  res.format({
    html: function() {
      res.redirect('/account/new');
    },
    json: function() {
      res.writeHead(401, { 'WWW-Authenticate': 'Basic realm="ChatCave Server"' });
      res.send();
    }
  });
};

exports.checkCredentials = function(req, res, next) {
  if (doesRequestHaveUserInSession(req) || canRequestBeUnauthenticated(req)) {
    next();
  }
  else {
    checkForAuthorization(req, res, next);
  }
};

//append request and session to use directly in views and avoid passing around needless stuff
exports.appendLocalsToUseInViews = function(req, res, next) {
  res.locals.request = req;

  if(req.session != null && req.session.user_id != null) {
    res.locals.user_id = req.session.user_id;
  }

  next(null, req, res);
};