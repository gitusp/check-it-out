require ['etc/lang', 'flow/load', 'models/app'], (lang, load, appModel) ->
	editing = false
	step = 0
	steps = [
		{
			# PHASE: IMAGE UPLOAD
			enter: ->
				if appModel.canPasteImage
					# bind paste
					($ document).on 'paste', (e) ->
						e.preventDefault()
						alert lang.noImagesInClipBoard unless load e.originalEvent.clipboardData.items, (src) ->
							appModel.imageSource src
							next()

				if appModel.canDropImage
					# bind drop
					($ document).on 'dragover dragenter', (e) ->
						e.preventDefault()

					($ document).on 'drop', (e) ->
						e.preventDefault()
						alert lang.noImagesInDragData unless load e.originalEvent.dataTransfer.files, (src) ->
							appModel.imageSource src
							next()

			exit: ->
				($ document).off 'paste dragover dragenter drop'
				editing = true
		}
		{
			# PHASE: EDIT IMAGE
			enter: ->
				appModel.state 'editor'
				appModel.editor.subscribe (va) ->
					console.log va

			exit: ->
		}
		{
			# PHASE: SHARE
			enter: ->
		}
	]
	next = ->
		steps[step - 1].exit() if steps[step - 1]?
		steps[step].enter()
		step++

	# apply knockout
	ko.applyBindings appModel, document.body

	# before leave
	($ window).on 'beforeunload', ->
		lang.areYouSureToLeave if editing

	# external callback
	window.uploadImageCallback = (image) ->
		appModel.imageSource image
		next()

	# boot strap
	if appModel.appUnavailable then alert lang.notCompatible else next()
