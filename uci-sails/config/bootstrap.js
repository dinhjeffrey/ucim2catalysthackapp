/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#!/documentation/reference/sails.config/sails.config.bootstrap.html
 */

module.exports.bootstrap = function(cb) {

  //TODO use sails-factory
  //grant connect on database "uci-postgres" to "uci-user";
  //GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "uci-user";

  require('sails')

  sails.on('lifted', function() {

    /* spawning a thread to list all the data inside data directory */
    const spawn = require('child_process').spawn;
    const ls = spawn('ls',['../cleandata']);

    ls.stdout.on('data', function (data) {
      console.log(`\nall cleaned csv data:\n ${data}`);
    });

    ls.stderr.on('data', function (data) {
      console.log(`stderr: ${data}`);
    });

    var pg = require('pg');
    var myConnectionString = "postgres://uci-user:uci-user@localhost/uci-postgres";
    var pgClient = new pg.Client(myConnectionString);
    pgClient.connect();
    //db config
    console.log('granting "uci-user" sudo privileges');
    var givesu = pgClient.query('GRANT CONNECT ON database "uci-postgres" to "uci-user"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public to "uci-user"');



    // ls.on('close', function (code) {
    //   console.log(`child process exited with code ${code}`);
    // });
    /* spawning a thread to list all the data inside data directory */


    // var postgresql = require('postgresql-adapter');
    // var connection = postgresql.createConnection({
    //   host     : sails.config.connections.somePostgresqlServer.host,
    //   user     : sails.config.connections.somePostgresqlServer.user,
    //   // password : sails.config.connections.mysql.password,
    //   database:  sails.config.connections.somePostgresqlServer.database
    // });
    // connection.query(queryString, function(err, records){
    //   // Do something
    // });
// var query = pgClient.query("COPY \"device\"(device_id,parent_device_id,company_id,device_uuid,device_type_id,device_type,device_os,carrier_name,mcc,mnc,n_mcc,n_mnc,s_mcc,s_mnc,r_mcc,r_mnc,language,latest_post,device_secret,create_date,cpu_info,cpu_max_speed) FROM '../cleandata/cleaneddevices.csv' DELIMITER ',' CSV HEADER;");



    var oneDevice = Device.find({where: { id: '*'},limit: 1})
    console.log(oneDevice);

    Device.find({limit:1}).exec((err,rec) => {
      var dev = rec.pop();
      console.log(dev)
    });

    Device.query(
      'COPY "device"('
      +'device_id,'
      +'parent_device_id,'
      +'company_id,'
      +'device_uuid,'
      +'device_type_id,'
      +'device_type,'
      +'device_os,'
      +'carrier_name,'
      +'mcc,'
      +'mnc,'
      +'n_mcc,'
      +'n_mnc,'
      +'s_mcc,'
      +'s_mnc,'
      +'r_mcc,'
      +'r_mnc,'
      +'language,'
      +'latest_post,'
      +'device_secret,'
      +'create_date,'
      +'cpu_info,'
      +'cpu_max_speed'
      +')'
      +"FROM '../cleandata/cleaneddevices.csv' DELIMITER ',' CSV HEADER;",
      function(err, results) {
        // if (err) return res.serverError(err);
        // return res.ok(results.rows);

        console.log('completed COPYING ../cleandata/cleaneddevice.csv to device table');

        /*clearing tables*/
        Device.query('DELETE FROM "device";', function(err,results) {
          console.log('DELETE FROM "device";\n');
        });
        /*clearing tables*/
      }
    )




  });







  //dirty way of instantiating dummy data each start of
  User.create([ {
    email: 'jeff@mail.com',
    password: 'ucidatahackathon',
    username: 'pastor'
  }, {
    email: 'charles@mail.com',
    password: 'ucidatahackathon',
    username: 'dumbo'
  }, {
    email: 'janice@mail.com',
    password: 'ucidatahackathon',
    username: 'catlady'
  }]).exec({
    error: function theBadFuture(err, res) {
      User.destroy([{
        email: 'jeff@maile.com',
      }, {
        email: 'charles@mail.com'
      }, {
        email: 'janice@mail.com'
      }]).exec(function (err,res) {
        // if (err) cb(res.negotiate(err));
      });
    },
    success: function theGoodFuture(err,res) {
    }
    // function(err,res) {
    // if (err) {
    // } else {
    // }
  });



  cb();

  // It's very important to trigger this callback method when you are finished
  // with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
  // cb();
};
