require ['etc/lang', 'flow/load', 'models/app', 'etc/helper'], (lang, load, appModel) ->
	editing = false
	step = 0
	steps = [
		{
			# PHASE: IMAGE UPLOAD
			enter: ->
				if appModel.canPasteImage
					# bind paste
					$(document).on 'paste.init', (e) ->
							e.preventDefault()
							alert lang.noImagesInClipBoard unless load e.originalEvent.clipboardData.items, setImage

				if appModel.canDropImage
					# bind drop
					$(document).on 'dragover.init dragenter.init', (e) ->
						e.preventDefault()

					$(document).on 'drop.init', (e) ->
						e.preventDefault()
						alert lang.noImagesInDragData unless load e.originalEvent.dataTransfer.files, setImage

			exit: ->
				$(document).off 'paste.init dragover.init dragenter.init drop.init'
		}
		{
			# PHASE: EDIT IMAGE
			enter: ->
				editing = true
				appModel.state 'editor'
				appModel.editor null

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
		$.post '/api/v1/share', {dna: json}, (result) ->
				if result.status == 'success'
					appModel.resultUrl "http://#{location.host}#{result.url}"
					appModel.deleteToken = result.token
					appModel.expire result.expire
					next()
				else
					alert lang.errorInServer
			, 'json'

	ko.applyBindings appModel, document.body

	# before leave
	$(window).on 'beforeunload', ->
		lang.areYouSureToLeave if editing

	# external callback
	window.uploadImageCallback = (src) ->
		appModel.nonBase64 = true
		setImage src

	# boot strap
	alert lang.notCompatible if appModel.appUnavailable
	next()

	# HACK: need real file input
	if appModel.needRealFileInput
		$('#content-portal input[type=file]').appendTo('#content-portal .upload').click((e) -> e.stopPropagation())
	