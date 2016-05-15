/**
 * Device.js
 *
 * Useful Attributes:
 *
 * device_id
 * company_id
 * device_uuid
 * device_type_id
 * device_type
 * device_os
 * home_timezone
 * device_name
 * carrier_name
 * language
 * latest_post
 * application_hash
 * api_key
 * create_date
 * cpu_info
 * cpu_max_speed
 * cpu_cor_labels
 * blocked
 * blocked_reason
 * unblock_date
 *
 * @description :: Data on each device
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
    // we will just use id for this
    device_id: {
      type: 'integer',
      // primaryKey: true,
      unique: true
    },
    parent_device_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    /*UNUSED*/
    m2_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    user_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    /*UNUSED*/
    company_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    device_uuid: {
      type: 'string',
      required: false,
      unique: false
    },
    device_type_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    device_type: {
      type: 'string',
      required: false,
      unique: false
    },
    device_os: {
      type: 'string',
      required: false,
      unique: false
    },
    home_timezone: {
      type: 'integer',
      required: false,
      unique: false
    },
    device_name: {
      type: 'string',
      required: false,
      unique: false
    },
    carrier_name: {
      type: 'string',
      required: false,
      unique: false
    },
    mcc: {
      type: 'integer',
      required: false,
      unique: false
    },
    mnc: {
      type: 'integer',
      required: false,
      unique: false
    },
    n_mcc: {
      type: 'integer',
      required: false,
      unique: false
    },
    n_mnc: {
      type: 'integer',
      required: false,
      unique: false
    },
    s_mcc: {
      type: 'integer',
      required: false,
      unique: false
    },
    s_mnc: {
      type: 'integer',
      required: false,
      unique: false
    },
    r_mcc: {
      type: 'integer',
      required: false,
      unique: false
    },
    r_mnc: {
      type: 'integer',
    },
    language: {
      type: 'string',
      required: false,
      unique: false
    },
    latest_post: {
      type: 'text',
      required: false,
      unique: false
    },
    device_secret: {
      type: 'string',
      required: false,
      unique: false
    },
    application_hash: {
      type: 'string',
      required: false,
      unique: false
    },
    api_key: {
      type: 'string',
      required: false,
      unique: false
    },
    create_date: {
      type: 'datetime',
      required: false,
      unique: false
    },
    cpu_info: {
      type: 'string',
      required: false,
      unique: false
    },
    cpu_max_speed: {
      type: 'string',
      required: false,
      unique: false
    },
    cpu_core_labels: {
      type: 'string',
      required: false,
      unique: false
    },
    blocked: {
      type: 'boolean',
      required: false,
      unique: false
    },
    blocked_reason: {
      type: 'text',
      required: false,
      unique: false
    },
    unblock_date: {
      type: 'datetime',
      required: false,
      unique: false
    },
    toJSON: function() {
      var device = this.toObject();
      return device;
    }
  }
};

