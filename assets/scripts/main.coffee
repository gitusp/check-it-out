require ['etc/lang', 'flow/load', 'models/app', 'etc/helper'], (lang, load, appModel) ->
	editing = false
	step = 0
	steps = [
		{
			# PHASE: IMAGE UPLOAD
			enter: ->
				if appModel.canPasteImage
					# bind paste
					$(document).on 'paste', (e) ->
							e.preventDefault()
							alert lang.noImagesInClipBoard unless load e.originalEvent.clipboardData.items, setImage

				if appModel.canDropImage
					# bind drop
					$(document).on 'dragover dragenter', (e) ->
						e.preventDefault()

					$(document).on 'drop', (e) ->
						e.preventDefault()
						alert lang.noImagesInDragData unless load e.originalEvent.dataTransfer.files, setImage

			exit: ->
				$(document).off 'paste dragover dragenter drop'
		}
		{
			# PHASE: EDIT IMAGE
			enter: ->
				editing = true
				appModel.state 'editor'
				# appModel.editor.subscribe (va) ->
				# 	console.log va

			exit: ->
				editing = false
		}
		{
			# PHASE: SHARE
			enter: ->
				appModel.state 'share'
		}
	]
	next = ->
		steps[step - 1].exit() if steps[step - 1]?
		steps[step].enter()
		step++
	setImage = (src) ->
		[tmpImage] = $('<img>').load(->
				appModel.imageSource src
				appModel.stageWidth tmpImage.width
				appModel.stageHeight tmpImage.height
				next()
			).error(->
				alert lang.unsupportedImage
			).attr 'src', src

	# apply knockout
	appModel.setShareCallback (json) ->
		# TODO: POST json
		# TODO: on API success
		next()

	ko.applyBindings appModel, document.body

	# before leave
	$(window).on 'beforeunload', ->
		lang.areYouSureToLeave if editing

	# external callback
	window.uploadImageCallback = setImage

	# boot strap
	if appModel.appUnavailable then alert lang.notCompatible else next()
