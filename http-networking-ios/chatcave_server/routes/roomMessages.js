var roomDB = require('../data/roomsDB.js');
var util = require('util');

/**
 * GET /rooms/:id/messages
 * Responds with a representation of the messages in the
 * chatroom identified by :id
 *
 * If the query parameter 'since' is provided with the
 * identifier of a message, only messages *since* that
 * identifier will be returned, otherwise all messages
 * will be returned
 *
 * Returns 404 if no such chatroom exists
 * (HTML, JSON)
 */
exports.get = function(req, res) {
  var roomID = req.params.id;
  var room = roomDB.getRoom(roomID);
  if (room !== null) {
    var messages = room.getMessages(req.query['since']);
    res.format({
      html: function() {
        res.render('messages', { title: room.name + " Messages", room: room, messages: messages });
      },
      json: function() {
        res.json(messages);
      }
    });
  }
  else {
    res.format({
      html: function() {
        res.render('missing', { title: 'No such room', req: req });
      },
      json: function() {
        res.json(404, { error: "No room with ID: " + roomID });
      }
    });
  }
};

 /**
  * POST /rooms/:id/messages
  * Adds a new message to the chatroom identified by :id.
  *
  * Post body should look like:
  *    message[text]=???
  *
  * Responds with 201 if message is successfully added
  * with a Location header of the newly created message
  * (/rooms/:room_id/messages/:message_id)
  *
  * Responds with a 404 if no such chatroom exists.
  * (HTML, JSON)
  */
exports.add = function(req, res) {
  var userID = req.session.user_id;
  if (userID !== null) {
    var roomID = req.params.id;
    var room = roomDB.getRoom(roomID);
    if (roomID != null) {
      var text = req.body.message.text;
      try {
        var message = room.addMessage(userID, text, 'chat');
        res.format({
          html: function() {
            res.redirect('/rooms/' + roomID + '/messages');
          },
          json: function() {
            res.location('/rooms/' + roomID + '/messages/' + message.id);
            res.json(201, message);
          }
        });
      }
      catch(e) {
        res.format({
          html: function() {
            res.send(406, e.message);
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
          res.render('missing', { title: 'No such room', req: req });
        },
        json: function() {
          res.json(404, { error: "No room with ID: " + roomID });
        }
      });
    }
  }
  else {
    res.format({
      html: function() {
        res.send(406, 'No user associated with current session');
      },
      json: function() {
        res.json(406, { error: 'No user associated with current session'} );
      }
    });
  }
};