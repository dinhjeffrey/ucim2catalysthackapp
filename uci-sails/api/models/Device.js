/**
 * Device.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
    device_id: {
      type: 'integer',
      required: true,
      unique: true
    },
    parent_device_id: {
      type: 'integer',
      required: false,
      unique: false
    },

    company_id: {
      type: 'integer',
      required: false,
      unique: false
    },
    device_uuid: {
      type: 'string',
      required: true,
      unique: true
    },
    device_type_id: {
      type: ''
    },
    device_type: {

    },
    device_os: {

    },
    home_timezone: {

    },




    /*UNUSED*/
    m2_id: {

    },
    user_id: {

    }
  }
};

