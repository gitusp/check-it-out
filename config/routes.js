module.exports.routes = {
	
	// To route the home page to the "index" action of the "home" controller:
	'get /' : {
		controller	: 'pages'
	},

	// キャプチャ用internal
	'get /capture' : {
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

	// api
	'post /api/v1/key': {
		controller	: 'apiv1',
		action		: 'key'
	},

	// シェア用url
	'get /s/:hash': {
		controller	: 'apiv1',
		action		: 'show'
	},

	// 削除用url
	'/s/:hash/:key': {
		controller	: 'apiv1',
		action		: 'delete'
	},
};
