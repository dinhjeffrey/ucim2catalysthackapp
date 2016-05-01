var crypto = require('crypto');
var util = require('util');
var uuid = require('node-uuid');

// Datastore setup
var Datastore = require('nedb');
var UserStore = new Datastore({
  filename: "users.db",
  autoload: true,
});

UserStore.ensureIndex({ fieldName: 'name', unique: true }, function(err) {
  if (err !== null) {
    console.error("Unable to set uniqueness constraint on user names: " + err);
  }
});

var cleanupUser = function(user) {
  return {
    'id': user._id,
    'name': user.name,
    'apiKey': user.apiKey
  };
}

/**
 * The data source for all users in the system
 */
var UserDB = {
  /**
   * Fetch all users in the system (asynchronous)
   * @param callback a function that accepts two arguments: an error and
   * the found item. If the error parameter is null, you can safely assume
   * that retrieval worked correctly.
   */
  getUsers: function(callback) {
    UserStore.find({}, function(error, foundUsers) {
      var cleanUsers = foundUsers.map(function(user, i, a) {
        return cleanupUser(user);
      })

      callback(error, cleanUsers);
    });
  },

  /**
   * Add a new user with the given name to the system (asynchronous)
   * @param name the name of the user to add
   * @param password the password for the user to authenticate with
   * @param callback a function that accepts two arguments: an error
   * and the newly created user object. If the error parameter is
   * null you can assume that adding the new user was successful
   */
  addUser: function(name, password, callback) {
    var hash = crypto.createHash('sha512');
    hash.update(password, 'utf8');
    var passwordHash = hash.digest('base64');
    var apiKey = uuid.v4();
    UserStore.insert({ name: name, password: passwordHash, apiKey: apiKey }, function(err, newDocs) {
      console.log("addUser found " + util.inspect(newDocs));
      var newUser = null;
      if (typeof(newDocs) === 'Array' && newDocs.length === 1) {
        newUser = newDocs[0];
      }
      else {
        newUser = newDocs;
      }

      callback(err, cleanupUser(newUser));
    });
  },

  /**
   * Fetch the user matching the given ID (asynchronous)
   * @param id the unique identifier of the user
   * @param callback a function that accepts two arguments: an error
   * and the retrieved user. If the error is null, you can assume that
   * retrieval was successful. If the returned user is null, then no
   * matching user was found for that identifier
   */
  getUser: function(id, callback) {
    UserStore.find({ _id: id }, function(err, foundDocs) {
      var user = null;
      if (foundDocs.hasOwnProperty('length')) {
        if (foundDocs.length === 1) {
          user = foundDocs[0];
        }
      }
      else {
        user = foundDocs;
      }


      callback(err, cleanupUser(user));
    });
  },

  /**
   * Attempt to fetch a user by API key.
   * @param apiKey
   *  @param callback A function that accepts two arguments: an error
   * and the matching user. If the error is null, check to see if the
   * user is null. If it is it means authentication failed
   */
  authenticateUserByKey: function(apiKey, callback) {
    UserStore.find({ apiKey: apiKey }, function(err, foundDocs) {
      var user = null;
      if (foundDocs.hasOwnProperty('length')) {
        if (foundDocs.length === 1) {
          user = foundDocs[0];
        }
      }
      else {
        user = foundDocs;
      }

      if (user !== null) {
        callback(null, cleanupUser(user));
      }
      else {
        callback(err, null);
      }
    });
  },

  /**
   * Fetch the user associated with the given name and verify the
   * given password
   * @param username
   * @param password
   * @param callback A function that accepts two arguments: an error
   * and the matching user. If the error is null, check to see if the
   * user is null. If it is it means authentication failed
   */
  authenticateUser: function(username, password, callback) {
    UserStore.find( { name: username }, function(err, foundDocs) {
      var user = null;
      if (foundDocs.hasOwnProperty('length')) {
        if (foundDocs.length === 1) {
          user = foundDocs[0];
        }
      }
      else {
        user = foundDocs;
      }

      if (user !== null) {
        var hash = crypto.createHash('sha512');
        hash.update(password, 'utf8');
        var hashedPassword = hash.digest('base64');

        if (user.password === hashedPassword) {
          callback(null, cleanupUser(user));
        }
        else {
          err = "Invalid password";
          callback(err, null);
        }
      }
      else {
        callback(err, null);
      }
    });
  },

  /**
   * Remove the user matching the given ID. (asynchronous)
   * @param id the unique identifier of the user to delete
   * @param callback A function that accepts two arguments: an error
   * and a count of the number of removed users. If the error argument
   * is null, you can assume the deleting operation proceeded accordingly.
   */
  deleteUser: function(id, callback) {
    UserStore.remove({ _id: id }, callback);
  }
};

module.exports = UserDB;