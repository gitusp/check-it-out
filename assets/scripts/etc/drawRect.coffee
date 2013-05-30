define ['etc/rect'], (rect, appModel) ->
	class extends rect
		constructor: (point = {x: 0, y: 0}, @borderColor = '#dd436f', @borderWidth = 2) ->
			super point

			# bg
			@entity.css {
					backgroundImage: "url(#{appModel.imageSource()})"
				}

			# shadow
			$('<div class="shadow">').appendTo @entity

			# border
			$('<div class="border-top">').height(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-right">').width(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-bottom">').height(@borderWidth).css('background', @borderColor).appendTo @entity
			$('<div class="border-left">').width(@borderWidth).css('background', @borderColor).appendTo @entity

			# add to models rects
			appModel.rects.push @

		draw: ->
			super()
			bgpx = - @getLeft() + appModel.stageOffsetX()
			bgpy = - @getTop() + appModel.stageOffsetY()
			@entity.css {
					backgroundPosition: "#{bgpx}px #{bgpy}px"
				}

		# destructor
		dispose: ->
			appModel.rects.remove @
			super()

		# static
		@setAppModel: (am) ->
			appModel = am