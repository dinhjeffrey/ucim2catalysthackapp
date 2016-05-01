require('array.prototype.findindex');
var uuid = require('node-uuid');

/**
 * The Message class
 */
function Message(author, text, type) {
  this.text = text;
  this.author = author;
  this.type = type;
  this.timestamp = new Date();
  this.id = uuid.v1();
};

/**
 * The Room class
 */
function Room(name) {
  this.name = name;
  this.id = uuid.v1();
  this.chatters = new Array();
  this.messages = new Array();
};

/**
 * Return all chatters (users) in this Room instance
 */
Room.prototype.getChatters = function() {
  return this.chatters.slice(0); // Send back a copy
};

/**
 * Add a chatter (User) to the room if they aren't already in it
 */
Room.prototype.addChatter = function(newChatter) {
  for (var i = this.chatters.length - 1; i >= 0; i--) {
    var chatter = this.chatters[i];
    if (chatter.id === newChatter.id) {
      console.warn("User " + newChatter.id + " is already in room " + this.id);
      return;
    };
  };

  this.chatters.push(newChatter);
};

/**
 * Remove the chatter (User) with the given ID from this room
 */
Room.prototype.removeChatter = function(chatterID) {
  for (var i = 0; i < this.chatters.length; i++) {
    if (this.chatters[i].id === chatterID) {
      this.chatters.splice(i, 1);
      console.info("Removed user '" + chatterID + "' from room " + this.id);
      return;
    };
  };

  console.warn("No user " + chatterID + " found in room " + this.id);
};

/**
 * Indicates if a chatter with the given ID is in this room
 */
Room.prototype.containsChatter = function(chatterID) {
  console.log("containsChatter(" + chatterID + ")");
  for (var i = 0; i < this.chatters.length; i++) {
    var chatter = this.chatters[i];
    if (chatter.id === chatterID) {
      return true;
    }
  }

  return false;
};

/**
 * Returns all messages in the chat room.
 * @param since An optional parameter which limits which
 * messages will be returned. Can be `null`
 */
Room.prototype.getMessages = function(since) {
  var messages = this.messages.slice(0);
  if (since === undefined || since === null) {
    return messages;
  }
  else {
    var idx = messages.findIndex(function(e,i,a) {
      return e.id === since;
    });

    return messages.splice(idx + 1);
  }
};

/**
 * Adds a new message to the given room.
 * @param author The name of the author of the message
 * @param text The text of the message to add
 * @param type The type of message to add (one of 'chat', 'leave' or 'join')
 * @return The newly added message
 */
Room.prototype.addMessage = function(authorID, text, type) {
  var authorIndex = this.chatters.findIndex(function(e,i,a) {
    return e.id === authorID;
  });

  if (authorIndex > -1) {
    var author = this.chatters[authorIndex];
    var message = new Message(author.name, text, type);
    this.messages.push(message);
    return message;
  }
  else {
    throw new Error("User " + authorID + " is not a member of this chatroom");
  }
};

/**
 * The global storage of chat rooms
 */
var RoomsDataSource = {
  _rooms: new Array(),

  /**
   * Get a copy of all the current chatrooms
   */
  getAllRooms: function() {
    return this._rooms.slice(0);
  },

  /**
   * Add a room with the given name
   * @throws Error if the room already exists
   */
  addRoom: function(name) {
    for (var i = 0; i < this._rooms.length; i++) {
      var room = this._rooms[i];
      if (room.name === name) {
        throw Error("A room named '" + name + "' already exists");
      };
    };

    var newRoom = new Room(name);
    this._rooms.push(newRoom);
    return newRoom;
  },

  /**
   * Delete a room with the given ID and return `true`
   * if the room is found and has no chatters.
   *
   * If it is found and does have chatters, an error
   * will be thrown.
   *
   * If the room is not found, this returns `false`
   */
  deleteRoom: function(id) {
    for (var i = 0; i < this._rooms.length; i++) {
      var room = this._rooms[i];
      if (room.id === id) {
        if (room.getChatters().length > 0) {
          throw Error("Room " + id + " still has chatters");
        };
        this._rooms = this._rooms.splice(i, 0);
        return true;
      };
    };

    console.warn("No room found with ID " + id);
    return false;
  },

  /**
   * Get the room with the given room ID
   * @return The room or `null` if no matching room is found
   */
  getRoom: function(id) {
    for (var i = 0; i < this._rooms.length; i++) {
      var room = this._rooms[i];
      if (room.id === id) {
        return room;
      };
    };

    console.warn("No room found with ID '" + id + "'");
    return null;
  }
};

module.exports = RoomsDataSource;