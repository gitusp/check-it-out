require ['etc/lang'], (lang) ->
	useragent = navigator.userAgent.toLowerCase()
	editing = false
	step = 0
	steps = [
		{
			# PHASE: IMAGE UPLOAD
			enter: ->
				if model.canPasteImage
					# bind paste
					($ document).on 'paste', (e) ->
						e.preventDefault()
						alert lang.noImagesInClipBoard unless loadItems e.originalEvent.clipboardData.items

				if model.canDropImage
					# bind drop
					($ document).on 'dragover', (e) ->
						e.preventDefault()

					($ document).on 'dragenter', (e) ->
						e.preventDefault()

					($ document).on 'drop', (e) ->
						e.preventDefault()
						alert lang.noImagesInDragData unless loadItems e.originalEvent.dataTransfer.files

				# common item loader
				loadItems = (items) ->
					# get image
					[image] = for datam in items
						datam if /image\/.+/.test datam.type
					return false unless image?

					# read image
					reader = new FileReader
					reader.onload = (e) ->
						model.imageSource e.target.result
						next()

					file = if image.getAsFile? then image.getAsFile() else image
					reader.readAsDataURL file
					true

			exit: ->
				($ document).off 'paste dragover dragenter drop'
				editing = true
		}
		{
			# PHASE: EDIT IMAGE
			enter: ->
				model.state 'editor'
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

	model = new class
		constructor: ->
			# feature detection
			@canPasteImage = /chrome/.test useragent
			@canDropImage = /chrome|safari|firefox|msie 10/.test useragent

			# model
			@imageSource = ko.observable '/images/spacer.gif'
			@state = ko.observable 'portal'

			# methods
			@upload = (d, e) ->
				(($ e.target).closest 'form').submit()
			@imageError = ->
				alert lang.unsupportedImage

	ko.applyBindings model, document.body

	# before leave
	($ window).on 'beforeunload', ->
		lang.areYouSureToLeave if editing

	# external callback
	window.uploadImageCallback = (image) ->
		model.imageSource image
		next()

	# boot strap
	unless /msie (6|7)/.test useragent then next() else alert lang.notCompatible
