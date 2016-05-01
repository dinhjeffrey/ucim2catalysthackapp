API = [
  {
    "path": "/rooms",
    "methods": {
      "GET": "Fetch all current chatrooms available in the system",
      "POST": "Create a new chatroom"
    }
  },
  {
    "path": "/rooms/:id",
    "methods": {
      "GET": "Fetch the details of a specific chatroom",
      "DELETE": "Destroy the chatroom"
    }
  },
  {
    "path": "/rooms/:id/messages",
    "methods": {
      "GET": "Fetch the messages for a given room. Use optional 'since' query parameter to get latest results",
      "POST": "Add a message to this chatroom"
    }
  },
  {
    "path": "/rooms/:id/chatters",
    "methods": {
      "GET": "Fetch all the chatters for the given room"
    }
  },
  {
    "path": "/rooms/:room_id/chatters/:chatter_id",
    "methods": {
      "PUT": "Add the user to the chatroom",
      "DELETE": "Leave the chatroom"
    }
  }
];

exports.list = function(req, res) {
  res.format({
    html: function() {
      res.redirect('/rooms')
    },
    json: function() {
      res.json(API);
    }
  })
};