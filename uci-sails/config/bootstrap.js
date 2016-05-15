/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#!/documentation/reference/sails.config/sails.config.bootstrap.html
 */

module.exports.bootstrap = function(cb) {

  //TODO use sails-factory
  

  //dirty way of instantiating dummy data each start of
  User.create([ {
    email: 'jeff@mail.com',
    password: 'ucidatahackathon',
    username: 'pastor'
  }, {
    email: 'charles@mail.com',
    password: 'ucidatahackathon',
    username: 'dumbo'
  }, {
    email: 'janice@mail.com',
    password: 'ucidatahackathon',
    username: 'catlady'
  }]).exec({
    error: function theBadFuture(err, res) {
      User.destroy([{
        email: 'jeff@maile.com',
      }, {
        email: 'charles@mail.com'
      }, {
        email: 'janice@mail.com'
      }]).exec(function (err,res) {
        // if (err) cb(res.negotiate(err));
      });
      cb()
    },
    success: function theGoodFuture(result) {
      cb();
    }
    // function(err,res) {
    // if (err) {
    //   cb(err);
    // } else {
    //   cb();
    // }
  });
  // It's very important to trigger this callback method when you are finished
  // with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
  // cb();
};
