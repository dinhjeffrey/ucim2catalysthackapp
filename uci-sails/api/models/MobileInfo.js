/**
 * MobileInfo.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
    entry_date: {
      type: 'datetime',
      required: false,
      unique: false
    },
    timestamp: {
      type: 'datetime',
      required: false,
      unique: false
    },
    device_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    base_station_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    base_station_long: {
      type: 'integer',
      required: false,
      unique: false
    },
    base_station_lat: {
      type: 'float',
      required: false,
      unique: false
    },
    cid: {
      type: 'integer',
      required: false,
      unique: false
    },
    lac: {
      type: 'string',
      required: false,
      unique: false
    },
    network_id: {
      type: 'string',
      required: false,
      unique: false
    },
    system_id: {
      type: 'string',
      required: false,
      unique: false
    },
    phone_type: {
      type: 'string',
      required: false,
      unique: false
    },
    network_type: {
      type: 'string',
      required: false,
      unique: false
    },
    toJSON: function() {
      var mobileinfo = this.toObject()
      return mobileinfo
    }
  }
}; 

