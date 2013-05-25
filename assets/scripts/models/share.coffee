define ['etc/lang'], (lang) ->
	class
		constructor: ->
			@resultUrl = ko.observable()
			@deleteKey = ko.observable()
			@deleteKeyStatus = ko.observable 'none'

			# realtime POST
			@deleteKey.subscribe (newValue) =>
				@deleteKeyStatus 'posting'
				clearTimeout @deleteKeyTimeout
				@deleteKeyTimeout = setTimeout =>
						$.post '/api/v1/key', {key: newValue}, (json) =>
								switch json.result
									when 'success'
										@deleteKeyStatus 'posted'
									else
										alert lang.errorInServer
							, 'json'
					, 1000
