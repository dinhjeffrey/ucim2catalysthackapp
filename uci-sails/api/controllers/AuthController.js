module.exports = {
	login: function(req, res, next) {
		console.log('inside AuthController.login')
		console.log(res)
		message = (req.body.email);

		res.render('profile');
	},
	logout: function(req, res) {
		res.redirect('/');
	}
}