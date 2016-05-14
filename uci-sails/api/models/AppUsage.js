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
  		type: 'integer', // from 'Devices' table
      unique: true
  	},
  	application_version_id: {
  		type: 'integer' // from 'Application Versions' table
  	},
  	type: {
  		type: 'integer'
  	},
  	start_date: {
  		type: 'datetime'
  	},
  	run_time: {
  		type: 'integer'
  	},
  	continuation: {
  		type: 'boolean'
  	},
  	year: {
  		type: 'integer'
  	},
  	month: {
  		type: 'integer'
  	},
  	day: {
  		type: 'integer'
  	},
  	package_name: {
  		type: 'string'
  	},
    toJSON: () => {
       var appUsage = this.toJSON()
       return appUsage
      }
  }
};

