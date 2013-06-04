var sv = require('local_shared_values');

module.exports = {
	
	// Name of the application (used as default <title>)
	appName: "checkout",

	// Port this Sails application will live on
	port: sv.port,

	// The environment the app is deployed in 
	// (`development` or `production`)
	//
	// In `production` mode, all css and js are bundled up and minified
	// And your views and templates are cached in-memory.  Gzip is also used.
	// The downside?  Harder to debug, and the server takes longer to start.
	environment: 'development',
	// environment: 'production',

	session: {
		secret: sv.sessionSecret,
		cookie: {domain: sv.host, maxAge: 60 * 60 * 24 * 1000}
	},

	// Logger
	// Valid `level` configs:
	// 
	// - error
	// - warn
	// - debug
	// - info
	// - verbose
	//
	log: {
		level: 'info'
	}

};
