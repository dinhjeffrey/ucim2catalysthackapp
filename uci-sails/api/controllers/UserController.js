/**
 * UserController
 *
 * @description :: Server-side logic for managing users
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */
/*
TODO make RESTful api controllers
1. show
2. create
3. update
4. destroy

 */

module.exports = {

  show: function(req,res,next) {
    User.find({id: /*req.body.id*/ req.params['id'] }).exec(function (err, userdata){
      if (err) return res.negotiate(err);
      var idJSON = JSON.stringify(userdata) // convert object to JSON
      res.ok(idJSON)
    });

  },

  create: function(req,res,next) {
    User.create([{
      email: req.body.email,
      password: req.body.password,
      username: req.body.username
    }]).exec({
      error: function(err, userdata) { res.negotiate(err) },

      success: function(err, userdata) {
        res.redirect('/login');
      }
    })
  },

  post: function(req,res,next) {
    //TODO this is your update functionality after user has logged in
  },

  destroy: function(req, res,next) {
    //TODO this is your delete user function if user decides to close his/her account
  },

  signup: function(req, res, next) {
		next()
  },

};

