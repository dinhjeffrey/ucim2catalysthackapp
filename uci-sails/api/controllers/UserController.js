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
    res.render(profile)
  },

  create: function(req,res,next) {
    //TODO this is  your signup function
    console.log('in UserController.create')
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

  //you generally don't want to do this - use RESTful api controllers -> this means
	// netflix: function (req, res) {
	// 	console.log('hitting netflix')
	// 	User.create({
	// 		email: 'netflix@and.chill',
	// 		password: 'pass',
	// 		username: 'netflix'
	// 	}).exec(function (err) {
	// 		// the future
	// 		if (err) return res.negotiate(err)

	// 		res.send("it worked!")
	// 	})
	// }
};
// test

