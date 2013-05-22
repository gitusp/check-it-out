define [], ->
	new class
		constructor: ->
			@imageSource = ko.observable '/images/spacer.gif'
			@stageWidth = ko.observable 0
			@stageHeight = ko.observable 0
			@stageOffsetX = ko.observable 0
			@stageOffsetY = ko.observable 0
			@rects = ko.observableArray()
			@editor = ko.observable()
