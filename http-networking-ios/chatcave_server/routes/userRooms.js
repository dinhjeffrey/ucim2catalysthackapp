var usersDB = require('../data/usersDB.js');
var roomsDB = require('../data/roomsDB.js');
var util = require('util');

/**
 * Helper function for fetching the appropriate Room based on
 * request parameters
 */
function getRoom(req) {
  return roomsDB.getRoom(req.params.room_id);
}

/**
 * Helper function for fetching the appropriate User based on
 * request parameters
 */
function getUser(req, callback) {
  return usersDB.getUser(req.params.user_id, callback);
}

/**
 * Helper function to convert "_id" attributes to "id" in final
 * JSON of user objects for public consumption
 */
function cleanUser(user) {
  return {
    "id": user._id,
    "name": user.name
  };
}

/**
 * GET /rooms/:room_id/chatters
 * Responds with a representation of the users for the chat room
 * identified by the given ID (HTML, JSON)
 */
exports.list = function(req, res) {
  var room = getRoom(req);
  if (room) {
    var users = room.getChatters();
    res.format({
      html: function() {
        res.render('rooms/users', { title: 'Chatters', room: room, users: users });
      },

      json: function() {
        res.json(users.map(cleanUser));
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.send(404, "No such room exists")
      },

      json: function() {
        res.json(404, { error: "No such room exists" });
      }
    });
  }
};

/**
 * PUT /rooms/:room_id/chatters/:user_id
 * Add the given user (identified by :user_id) to the given
 * chat room (identified by :room_id) (HTML, JSON)
 */
exports.add = function(req, res) {
  var room = getRoom(req);
  if (room) {
    var user = getUser(req, function(error, user) {
      if (user) {
        room.addChatter(user);
        room.addMessage(user.id, null, 'join');
        res.format({
          html: function() {
            res.redirect('/rooms/' + req.params.room_id);
          },
          json: function() {
            res.json(201, { users: room.getChatters().map(cleanUser) });
          }
        })
      }
      else {
        console.warn(req.path + ": " + util.inspect(error));
        res.format({
          html: function() {
            res.send(404, "No such user exists");
          },
          json: function() {
            res.json(404, { error: "No such user exists" });
          }
        })
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.send(404, "No such room exists");
      },
      json: function() {
        res.json(404, { error: "No such room exists" });
      }
    });
  }
};

/**
 * DELETE /rooms/:room_id/chatters/:user_id
 * Removes the user (identified by :user_id) from the given room
 * (identified by the :room_id)
 */
exports.delete = function(req, res) {
  var room = getRoom(req);
  if (room) {
    room.addMessage(req.params.user_id, null, 'leave');
    room.removeChatter(req.params.user_id);
    res.format({
      html: function() {
        res.redirect('/rooms');
      },

      json: function() {
        res.json(200, {});
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.send(404, "No such room exists");
      },

      json: function() {
        res.send(404, { error: "No such room exists" });
      }
    });
  }
};