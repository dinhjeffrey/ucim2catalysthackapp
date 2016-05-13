module.exports = {
	login: function(req, res, next) {
		res.render('profile', {
			email: req.body.email
		});
	},
	logout: function(req, res) {
		res.redirect('/');
	}
}
