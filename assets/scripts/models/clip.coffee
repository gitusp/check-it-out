define ['etc/rect'], (rect) ->
	workSpace = $('#clip-work-space')

	new class
		constructor: ->
			# methodだとスコープ固定できないので
			@startClip = (d, e) =>
				@clean()
				@clipRect = new rect 0, {x: e.offsetX, y: e.offsetY}
				workSpace.append @clipRect.entity
				@clipRect.startDraw {x: e.pageX, y: e.pageY}

		clean: ->
			@clipRect.dispose() if @clipRect?
			@clipRect = null
