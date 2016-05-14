/**
 * ApplicationVersions.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {
// 25926841	com.period.tracker.lite	Period Tracker	2.0.6.4	GP International LLC	2	4	5	android.permission.INTERNET android.permission.ACCESS_NETWORK_STATE android.permission.WRITE_EXTERNAL_STORAGE android.permission.VIBRATE	4	0		20672512	NULL	https://lh4.ggpht.com/3NneKQ51rekn6NVjrlQ2z16833MTw253i70YnQXug_GRj0rkbS6NWC3GMdzmEwvQBQ=w300	0	663646	12/20/14 13:52	9/28/15 18:48
  attributes: {
  	application_version_id: {
  		type: 'integer', // from 'Devices' table
      primaryKey: true,
      unique: true
  	},
  	package_name: {
  		type: 'string' 
  	},
  	name: {
  		type: 'string'
  	},
  	version: {
  		type: 'string'
  	},
  	developer: {
  		type: 'string'
  	},
  	app_type: {
  		type: 'integer',
  	},
  	category: {
  		type: 'integer',
  	},
  	m2_category: {
  		type: 'integer',
  	},
  	permissions: {
  		type: 'string'
  	},
  	permission_weight: {
  		type: 'integer',
  	},
  	notification_score: {
  		type: 'integer',
  	},
  	analytic_providers: {
  		type: 'string'
  	},
  	apk_size: {
  		type: 'integer',
  	},
  	ignore_category: {
  		type: 'string' // NULL
  	},
  	icon_link: {
  		type: 'string'
  	},
  	not_on_play: {
  		type: 'integer',
  	},
  	create_device_id: {
  		type: 'integer',
  	},
  	create_date: {
  		type: 'datetime'
  	},
  	update_date: {
  		type: 'datetime'
  	},
    toJSON: function() {
      var applicationVersions = this.toJSON()
      return applicationVersions
    }
  }
};

