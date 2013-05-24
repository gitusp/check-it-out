module.exports.routes = {
	
	// To route the home page to the "index" action of the "home" controller:
	'/' : {
		controller	: 'pages'
	},

	// キャプチャ用internal
	'/capture' : {
		controller	: 'pages',
		action		: 'capture'
	},

	// api
	'post /api/v1/upload': {
		controller	: 'apiv1',
		action		: 'upload'
	},

	// api
	'post /api/v1/share': {
		controller	: 'apiv1',
		action		: 'share'
	},

	// シェア用url
	'/s/:hash': {
		controller	: 'apiv1',
		action		: 'show'
	},
};
