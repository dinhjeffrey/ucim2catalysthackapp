/**
 * MobileSignalInfo.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
  	entry_date: {
  		type: 'datetime' // NOT IN TABLE
  	},
  	timestamp: {
  		type: 'datetime'
  	},
  	device_id: {
  		type: 'integer'
  	},
  	cdma_dbm: {
  		type: 'integer'
  	},
  	cdma_asu_level: {
  		type: 'integer'
  	},
  	cdma_ecio: {
  		type: 'integer'
  	},
  	evdo_dbm: {
  		type: 'integer'
  	},
  	evdo_asu_level: {
  		type: 'integer'
  	},
  	evdo_ecio: {
  		type: 'integer'
  	},
  	gsm_dbm: {
  		type: 'integer'
  	},
  	gsm_asu_level: {
  		type: 'integer'
  	},
  	lte_dbm: {
  		type: 'integer'
  	},
  	lte_asu_level: {
  		type: 'integer'
  	},
  	lte_rsrp: {
  		type: 'integer'
  	},
  	wcdma_dbm: {
  		type: 'integer'
  	},
	wcdma_asu_level: {
		type: 'integer'
	},
	longitude: {
		type: 'float'
	},
	latitude: {
		type: 'float'
	}
  }
};

