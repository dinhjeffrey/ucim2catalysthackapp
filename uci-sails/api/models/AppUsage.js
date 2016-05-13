/**
 * AppUsage.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {
//device_id	application_version_id	type	start_date	run_time	continuation	year	month	day	package_name
// 33919	7096	4	9/1/15 0:05	2063506	FALSE	2015	9	1	com.motricity.verizon.ssodownloadable  
attributes: {
  	device_id: {
  		type: 'number' // from 'Devices' table
  	},
  	application_version_id: {
  		type: 'number' // from 'Application Versions' table
  	},
  	type: {
  		type: 'number'
  	},
  	start_date: {
  		type: 'string'
  	},
  	run_time: {
  		type: 'number'
  	},
  	continuation: {
  		type: 'boolean'
  	},
  	year: {
  		type: 'number'
  	},
  	month: {
  		type: 'number'
  	},
  	day: {
  		type: 'number'
  	},
  	package_name: {
  		type: 'string'
  	}
  }
};

