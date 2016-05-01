var usersDB = require('../data/usersDB.js');
var roomsDB = require('../data/roomsDB.js');
var util = require('util');

/**
 * GET /users
 * Responds with a representation of all current users
 * (HTML, JSON)
 */
exports.list = function(req, res){
  usersDB.getUsers(function(err, users) {
    if (err !== null) {
      throw new Error(err);
    };

    res.format({
      html: function() {
        res.render('users', { title: "All Users", users: users, request: req });
      },

      json: function() {
        res.json(users);
      }
    });
  });
};

/**
 * GET /users/new
 * Responds with a resource that is a HTML form for creating
 * a new user
 * (HTML)
 */
exports.newForm = function(req, res) {
  res.render('newUser', { title: "Create a New User" });
};

/**
 * GET /users/:id
 * Responds with a representation for the user identified by :id
 * (HTML, JSON)
 */
exports.get = function(req, res) {
  var userID = req.params.id;
  usersDB.getUser(userID, function(error, user) {
    if (error !== null) {
      throw new Error(error);
    };

    if (user !== null) {
      res.format({
        html: function() {
          res.render('user', { title: user.name, user: user });
        },

        json: function() {
          res.json(user);
        }
      });
    }
    else {
      res.format({
        html: function() {
          res.send(404, "No user found with ID: " + userID);
        },

        json: function() {
          res.json(404, { error: "No user found with ID: " + userID });
        }
      });
    }
  });
}

/**
 * POST /users
 * Add a new user to the users collection with the given form body:
 *    user[name]=???
 *    user[password]=???
 *
 * (HTML, JSON)
 */
exports.create = function(req, res) {
  var userName = req.body.user.name;
  var password = req.body.user.password;
  if (userName !== null && userName.length > 0 && password !== null && password.length > 0) {
    usersDB.addUser(userName, password, function(error, user) {
      if (error !== null) {
        res.format({
          html: function() {
            res.send(406, error.message);
          },
          json: function() {
            res.json(406, error);
          }
        })
      }
      else {
        req.session.user_id = user.id;
        res.format({
          html: function() {
            res.render('user', { title: 'User', user: user });
          },

          json: function() {
            res.json(201, user);
          }
        });
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.render('newUser', { title: 'Try Again', error: "You must specify a user name and password." });
      },

      json: function() {
        res.json(406, { error: "You must specify user[name] and user[password]" });
      }
    })
  };
};

/**
 * DELETE /users/:id
 * Removes the user identified by :id
 * This will respond with a 406 if the user is still attached to any chat rooms
 * If successful, it redirects (302) to /users.
 */
exports.delete = function(req, res) {
  var userID = req.params.id;

  // Go through each room to make sure the user isn't still in a conversation
  var rooms = roomsDB.getAllRooms();
  for (var i = 0; i < rooms.length; i++) {
    var room = rooms[i];
    var chatters = room.getChatters();
    for (var j = 0; j < chatters.length; i++) {
      if (chatters[j].id === userID) {
        res.format({
          html: function() {
            res.send(406, "User " + userID + " is still in chat-room " + room.id);
          },

          json: function() {
            res.json(406, { error: "User " + userID + " is still in chat-room " + room.id });
          }
        });

        return;
      };
    };
  };

  usersDB.deleteUser(userID, function(error, numDeleted) {
    if (error !== null) {
      throw new Error(error);
    };

    res.format({
      html: function() {
        res.redirect('/users');
      },

      json: function() {
        res.redirect('/users');
      }
    });
  });
};