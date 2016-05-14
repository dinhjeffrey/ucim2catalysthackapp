/**
 * WifiInfo.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
  	entry_date: {
  		type: 'datetime'
  	},
	timestamp: {
		type: 'integer'
	},
	device_id: {
		type: 'string'
	},
	ssid: {
		type: 'string'
	},
	ip_address: {
		type: 'string'
	},
	connection_speed: {
		type: 'integer'
	},
	connected_wifi_band_frequency: {
	type: 'integer'
	},
	signal_strength_dbm: {
	type: 'integer'
  },
  toJSON: function() {
  	var obj = this.toObject()
  	return obj
  }
}
};

