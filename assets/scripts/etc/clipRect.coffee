define ['etc/rect'], (rect) ->
	class extends rect
		constructor: (point = {x: 0, y: 0}, @onDraw = ->) ->
			super point

		draw: ->
			super()
			@onDraw @getTop(), @getRight(), @getBottom(), @getLeft()