var roomDB = require('../data/roomsDB.js');
var util = require('util');

function jsonifyRoom(fullRoom) {
  return {
     name: fullRoom.name,
     id: fullRoom.id,
     chatters: fullRoom.chatters.map(jsonifyUser)
  };
}

function jsonifyUser(user) {
  return {
    "id": user._id,
    "name": user.name
  };
}

/**
 * GET /rooms
 * Responds with a representation of all available chat rooms
 * (HTML, JSON)
 */
exports.list = function(req, res) {
  res.format({
    html: function() {
      res.render('rooms', { title: "Chat Rooms", rooms: roomDB.getAllRooms() });
    },

    json: function() {
      res.json(roomDB.getAllRooms().map(function(room, i) {
        return jsonifyRoom(room);
      }));
    }
  });
};

/**
 * GET /rooms/new
 * Responds with a form to submit to create a new room
 * (HTML only)
 */
exports.newForm = function(req, res) {
  res.format({
    html: function() {
      res.render('newRoom', { title: "Create a new Chat Room" });
    }
  });
};

/**
 * POST /rooms
 *
 * Create a new room with the given form-encoded parameters:
 * body:
 *    room[name] = ???
 */
exports.create = function(req, res) {
  var roomName = req.body.room.name;
  if (roomName !== null) {
    try {
      var room = roomDB.addRoom(roomName);

      res.format({
        html: function() {
          res.redirect('/rooms/' + room.id);
        },

        json: function() {
          res.json(201, jsonifyRoom(room));
        }
      });
    }
    catch (e) {
      res.format({
        html: function() {
          res.render('rooms', {
            title: 'All Rooms',
            rooms: roomDB.getAllRooms().map(function(room, i) {
              return jsonifyRoom(room);
            }),
            error: e.message
          });
        },

        json: function() {
          res.json(406, { error: e.message });
        }
      });
    }
  }
  else {
    res.format({
      html: function() {
        res.render('rooms', {
          title: 'All Rooms',
          rooms: roomDB.getAllRooms(),
          error: "You must provide a room name"
        });
      },

      json: function() {
        res.json(406, { error: 'You must provide room[name]' });
      }
    });
  };
};

/**
 * GET /rooms/:id
 * Responds with a representation of the room for the given identifier
 * (HTML, JSON)
 */
exports.get = function(req, res) {
  var roomID = req.params.id;
  var room = roomDB.getRoom(roomID);
  if (room !== null) {
    res.format({
      html: function() {
        var userID = req.session['user_id'];
        res.render('room', { title: "Chat Room: " + room.name, room: room, userID: userID });
      },

      json: function() {
        res.json(jsonifyRoom(room));
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.render('missing', { title: 'No such room', req: req });
      },

      json: function() {
        res.json(404, { error: "No room exists with ID '" + roomID + "'" });
      }
    });
  };
};

/**
 * DELETE /rooms/:id
 * Deletes a room with the given identifier
 */
exports.delete = function(req, res) {
  try {
    var result = roomDB.deleteRoom(req.params.id);
    if (result) {
      res.format({
        html: function() {
          res.redirect('/rooms');
        },

        json: function() {
          res.redirect('/rooms');
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
  }
  catch (e) {
    res.format({
      html: function() {
        res.send(406, "The room cannot be deleted with chatters still in it");
      },

      json: function() {
        res.json(406, { error: "The room cannot be deleted with chatters still in it"} );
      }
    });
  }
};