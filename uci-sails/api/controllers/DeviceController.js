/**
 * DeviceController
 *
 * @description :: Server-side logic for managing devices
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
	deviceModelBar: function(req,res,next) {
    Device.find({limit:req.params['limit']}).exec(function(err, devicedata) {
      if(err) return res.negotiate(err)
      console.log(JSON.stringify(devicedata));
      res.send(JSON.stringify(devicedata))
    })
  }


};

