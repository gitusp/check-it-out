define ['etc/rect'], (rect) ->
	workSpace = $('#clip-work-space')

	class
		constructor: ->
			# to fix scope
			@startClip = (d, e) =>
				@clean()
				@clipRect = new rect {x: e.offsetX, y: e.offsetY}
				workSpace.append @clipRect.entity
				@clipRect.startDraw {x: e.pageX, y: e.pageY}

		clean: ->
			@clipRect.dispose() if @clipRect?
			@clipRect = null
