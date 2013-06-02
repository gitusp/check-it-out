define ['etc/lang'], (lang) ->
	class
		constructor: ->
			@expire = ko.observable()
			@resultUrl = ko.observable()
			@deleteToken = null
			@deleteKey = ko.observable()
			@deleteKeyStatus = ko.observable 'none'
			@deleteUrl = ko.computed =>
				if @deleteKey() then "#{@resultUrl()}/#{@deleteKey()}" else ''

			# realtime POST
			@deleteKey.subscribe (newValue) =>
				@deleteKeyStatus 'posting'
				clearTimeout @deleteKeyTimeout
				@deleteKeyTimeout = setTimeout =>
						$.post '/api/v1/key', {key: newValue, token: @deleteToken}, (json) =>
								switch json.status
									when 'success'
										@deleteKeyStatus 'posted'
									else
										alert lang.errorInServer
							, 'json'
					, 1000
