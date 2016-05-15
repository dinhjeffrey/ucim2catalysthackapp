/**
 * DeviceBatteryStats.js
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
    charge_rate: {
      type: 'float',
      required: false,
      unique: false
    },
    drain_rate: {
      type: 'float',
      required: false,
      unique: false
    },
    delta_time: {
      type: 'float',
      required: false,
      unique: false
    },
    charging_or_draining: {
      type: 'boolean',
      required: false,
      unique: false
    },
    battery_percentage: {
      type: 'integer',
      required: false,
      unique: false
    },
    battery_temperature: {
      type: 'integer',
      required: false,
      unique: false
    },
    battery_voltage: {
      type: 'integer',
      required: false,
      unique: false
    },
    toJSON: function() {
      var devicebatterystats = this.toObject();
      return devicebatterystats;
    }

  }
};

