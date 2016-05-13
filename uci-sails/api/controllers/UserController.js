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
    //TODO this will be a redirect after you login
  console.log('in /api/controllers/UserController.show')
  User.find({id: /*req.body.id*/ req.params['id'] }).exec(function (err, idFound){
    if (err) return res.negotiate(err);
    var idJSON = JSON.stringify(idFound) // convert object to JSON
    res.ok(idJSON)
  sails.log('Wow, there are %d users with this id.  Check it out:', idFound.length, idFound);
  });

  },
  


  create: function(req,res,next) {  
    //TODO this is  your signup function
    console.log('in UserController.create')
    console.log(req)
    console.log(req.headers['user-agent'])
    User.create([{
      email: req.body.email,
      password: req.body.password,
      username: req.body.username
    }]).exec({
      error: function(requ, resu) { res.negotiate() },

      success: function(requ, resu) { 
                              
        res.send(`YES!!! created`) 
      }
    })
  },

  post: function(req,res,next) {
    //TODO this is your update functionality after user has logged in
    console.log('in UserController.post')
  },

  destroy: function(req, res,next) {
    //TODO this is your delete user function if user decides to close his/her account
    console.log('in UserController.destroy')
  },

  signup: function(req, res, next) {
		console.log('in UserController.signup')
		next()
  },

};

