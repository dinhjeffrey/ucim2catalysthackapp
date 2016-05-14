/**
 * ApplicationVersions.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {
// 25926841	com.period.tracker.lite	Period Tracker	2.0.6.4	GP International LLC	2	4	5	android.permission.INTERNET android.permission.ACCESS_NETWORK_STATE android.permission.WRITE_EXTERNAL_STORAGE android.permission.VIBRATE	4	0		20672512	NULL	https://lh4.ggpht.com/3NneKQ51rekn6NVjrlQ2z16833MTw253i70YnQXug_GRj0rkbS6NWC3GMdzmEwvQBQ=w300	0	663646	12/20/14 13:52	9/28/15 18:48
  attributes: {
  	device_id: {
  		type: 'number' // from 'Devices' table
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
  		type: 'number'
  	},
  	category: {
  		type: 'number'
  	},
  	m2_category: {
  		type: 'number'
  	},
  	permissions: {
  		type: 'string'
  	},
  	permission_weight: {
  		type: 'number'
  	},
  	notification_score: {
  		type: 'number'
  	},
  	analytic_providers: {
  		type: 'string'
  	},
  	apk_size: {
  		type: 'number'
  	},
  	ignore_category: {
  		type: 'NULL'
  	},
  	icon_link: {
  		type: 'string'
  	},
  	not_on_play: {
  		type: 'number'
  	},
  	create_device_id: {
  		type: 'number'
  	},
  	create_date: {
  		type: 'string'
  	},
  	update_date: {
  		type: 'string'
  	}
  }
};

