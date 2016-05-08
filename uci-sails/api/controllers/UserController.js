/**
 * UserController
 *
 * @description :: Server-side logic for managing users
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
	signup: function(req, res, next) {
		console.log('in /api/controllers/UserController.signup')
		next()
	},
	netflix: function (req, res) {
		console.log('hitting netflix')
		User.create({
			email: 'netflix@and.chill',
			password: 'pass',
			username: 'netflix'
		}).exec(function (err) {
			// the future
			if (err) return res.negotiate(err)

			res.send("it worked!")
		})
	}
};
// test

