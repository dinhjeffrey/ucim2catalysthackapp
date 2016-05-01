var usersDB = require('../data/usersDB.js');
var util = require('util');

/**
 * GET /account/new
 * The sign-in form (HTML)
 */
exports.signInForm = function(req, res) {
  res.render('signIn', { title: "Sign In" });
};

/**
 * PUT /account
 * Send username/password (form-encoded) to sign-in and
 * associate the matching user with the current session
 * (HTML, JSON)
 */
exports.signIn = function(req, res) {
  var username = req.body['user']['name'];
  var password = req.body['user']['password'];
  if (username !== null && username.length > 0 &&
      password !== null && password.length > 0) {
    usersDB.authenticateUser(username, password, function(err, user) {
      if (err !== null) {
        res.format({
          html: function() {
            res.render('signIn', { title: 'Sign In', error: err.message });
          },
          json: function() {
            res.json(401, { error: error });
          }
        })
      }
      else if (user !== null) {
        req.session.user_id = user.id;
        res.format({
          html: function() {
            res.redirect('/rooms');
          },
          json: function() {
            res.json(201, user);
          }
        });
      }
      else {
        res.format({
          html: function() {
            res.render('signIn', { title: 'Sign In', error: 'Invalid username/password combination' });
          },
          json: function() {
            res.json(401, { error: 'Invalid username/password combination'} );
          }
        });
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.render('signIn', { title: 'Sign In', error: "You must provide a username and password" });
      },
      json: function() {
        res.json(406, { error: "You must provide a username and password" });
      }
    })
  }
};

/**
 * DELETE /account
 * Signs the user out, effectively disassociating the user
 * with their current session.
 * (HTML, JSON)
 */
exports.signOut = function(req, res) {
  delete req.session['user_id']

  res.format({
    html: function() {
      res.redirect('/account/new');
    },
    json: function() {
      res.json(200, {});
    }
  });
};
