define ['etc/rect'], (rect) ->
	workSpace = $('#draw-work-space')

	class
		constructor: ->
			# to fix scope
			@startDraw = (d, e) =>
				@clipRect = new rect {x: e.offsetX, y: e.offsetY}, 4, 'black'
				workSpace.append @clipRect.entity
				@clipRect.startDraw {x: e.pageX, y: e.pageY}

				# TODO: add to models rects
				# and subscribe rects and hide or show the whiten mask
