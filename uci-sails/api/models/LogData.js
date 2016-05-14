/**
 * LogData.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
    entry_date: { // NOT IN TABLE
      type: 'datetime',
      required: false,
      unique: false
    },
    device_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    devices_os: {
      type: 'integer',
      required: false,
      unique: false
    },
    company_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    device_entry_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    log_timestamp: { // ###### in table
      type: 'string',
      required: false,
      unique: false
    },
    package_name: {
      type: 'string',
      required: false,
      unique: false
    },
    application_version: {
      type: 'string',
      required: false,
      unique: false
    },
    application_version_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    version: {
      type: 'string',
      required: false,
      unique: false
    },
    battery: {
      type: 'integer',
      required: false,
      unique: false
    },
    back_battery: {
      type: 'integer',
      required: false,
      unique: false
    },
    cpu: {
      type: 'integer',
      required: false,
      unique: false
    },
    back_cpu: {
      type: 'integer',
      required: false,
      unique: false
    },
    memory: {
      type: 'integer',
      required: false,
      unique: false
    },
    data_all: {
      type: 'integer',
      required: false,
      unique: false
    },
    back_data: {
      type: 'integer',
      required: false,
      unique: false
    },
    data_wifi: {
      type: 'integer',
      required: false,
      unique: false
    },
    data_mobile: {
      type: 'integer',
      required: false,
      unique: false
    },
    crash_count: {
      type: 'integer',
      required: false,
      unique: false
    },
    run_time: {
      type: 'integer',
      required: false,
      unique: false
    },
    front_run_time: {
      type: 'integer',
      required: false,
      unique: false
    },
    code_size: {
      type: 'integer',
      required: false,
      unique: false
    },
    data_size: {
      type: 'integer',
      required: false,
      unique: false
    },
    cache_size: {
      type: 'integer',
      required: false,
      unique: false
    },
    other_size: {
      type: 'integer',
      required: false,
      unique: false
    },
    toJSON: function() {
      var obj = this.toObject()
      return obj
    }
  }
};

