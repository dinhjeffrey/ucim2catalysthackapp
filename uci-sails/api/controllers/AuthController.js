module.exports = {
	login: function(req, res, next) {
		console.log('in AuthController.login')
		res.render('profile', {
			email: req.body.email
		});
	},
	logout: function(req, res) {
		res.redirect('/');
	}
}