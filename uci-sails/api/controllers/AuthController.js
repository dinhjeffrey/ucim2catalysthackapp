module.exports = {
	login: function(req, res, next) {
		res.render('profile', {
			email: req.body.email
		});
	},
  process: function(req,res) {
    passport.authenticate('local',function(err,user,info) {
      if((err) || (!user)) {
        return res.send({
          message: 'login failed'
        })
        res.send(err)
      }
      req.logIn(user, function(err) {
        if(err) res.send(err);
        return res.send({
          message: 'login successful'
        })
      })
    })(req,res)
  },
	logout: function(req, res) {
		res.redirect('/');
	}
}
