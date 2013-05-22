define ['etc/clipRect'], (clipRect, appModel) ->
	workSpace = $ '#clip-work-space'
	[mask1, mask2, mask3, mask4] = for i in [1..4]
		$ ".mask#{i}", workSpace

	maskResizer = (top = 0, right = 0, bottom = 0, left = 0) ->
		mask1.height(top).width appModel.stageWidth() - left
		mask2.height(appModel.stageHeight() - top).width appModel.stageWidth() - right
		mask3.height(appModel.stageHeight() - bottom).width right
		mask4.height(bottom).width left

	class
		constructor: ->
			# to fix scope
			@startClip = (d, e) =>
				@clean()
				offset = workSpace.offset()
				@clipRect = new clipRect {x: e.pageX - offset.left, y: e.pageY - offset.top}, maskResizer
				workSpace.append @clipRect.entity
				@clipRect.startDraw {x: e.pageX, y: e.pageY}

		clean: ->
			@clipRect.dispose() if @clipRect?
			@clipRect = null
			maskResizer()

		# static
		@setAppModel = (am) ->
			am.editor.subscribe (newValue) ->
				maskResizer() if newValue == 'clip'
			appModel = am
