define ['etc/lang'], (lang) ->
	class
		constructor: ->
			@resultUrl = ko.observable()
			@deleteKey = ko.observable()
			@deleteKeyStatus = ko.observable 'none'
			@deleteUrl = ko.computed =>
				if @deleteKey() then "#{@resultUrl()}/#{@deleteKey()}" else false

			# realtime POST
			@deleteKey.subscribe (newValue) =>
				@deleteKeyStatus 'posting'
				clearTimeout @deleteKeyTimeout
				@deleteKeyTimeout = setTimeout =>
						$.post '/api/v1/key', {key: newValue}, (json) =>
								switch json.status
									when 'success'
										@deleteKeyStatus 'posted'
									else
										alert lang.errorInServer
							, 'json'
					, 1000
