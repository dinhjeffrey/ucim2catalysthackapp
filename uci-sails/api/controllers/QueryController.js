/**
 * QueryController
 *
 * @description :: Server-side logic for managing queries
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
	show: function(req,res,next) {
  console.log('in /api/controllers/QueryController.show')
  User.find({id: req.body.id }).exec(function (err, idFound){
    if (err) return res.negotiate(err);
    var idJSON = JSON.stringify(idFound) // convert object to JSON
    res.ok()
    // res.render('queryDone',{
    //   iFoundU: idJSON
    // }); 
  sails.log('Wow, there are %d users with this id.  Check it out:', idFound.length, idFound);
  });

  },
	
};

