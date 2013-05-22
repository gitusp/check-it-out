define ['etc/rect'], (rect, appModel) ->
	class extends rect
		constructor: (point = {x: 0, y: 0}, @borderColor = 'transparent', @borderWidth = 4) ->
			super point

			# bg
			@entity.css {
					backgroundImage: "url(#{appModel.imageSource()})"
				}

			# border
			$('<div class="border-top">').height(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-right">').width(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-bottom">').height(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-left">').width(@borderWidth).css('background', @borderColor).appendTo @entity

		draw: ->
			super()
			bgpx = - @getLeft() + appModel.stageOffsetX()
			bgpy = - @getTop() + appModel.stageOffsetY()
			@entity.css {
					backgroundPosition: "#{bgpx}px #{bgpy}px"
				}

		# static
		@setAppModel: (am) ->
			appModel = am