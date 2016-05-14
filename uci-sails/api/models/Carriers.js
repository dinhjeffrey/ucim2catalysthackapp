/**
 * Carriers.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
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
    carrier_name: {
      type: 'string',
      required: false,
      unique: false
    },
    toJSON: function() {
      var carriers = this.toJson()
      return carriers;
    }
  }
};

