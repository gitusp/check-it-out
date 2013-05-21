require ['etc/lang'], (lang) ->
	editing = false
	isDataURL = false
	step = 0
	steps = [
		{
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
						isDataURL = true
						model.imageSource e.target.result
						next()

					file = if image.getAsFile? then image.getAsFile() else image
					reader.readAsDataURL file
					true

			exit: ->
				($ document).off 'paste dragover drop'
				editing = true
		}
		{
			enter: ->
				model.state 'editor'
			exit: ->
		}
		{
			enter: ->
		}
	]
	next = ->
		steps[step - 1].exit() if steps[step - 1]?
		steps[step].enter()
		step++

	model = new class
		constructor: ->
			@canPasteImage = navigator.userAgent.toLowerCase().indexOf 'chrome' > -1
			# TODO detection
			@canDropImage = true

			# 
			@imageSource = ko.observable '/images/spacer.gif'
			@state = ko.observable 'portal'
			@upload = (e) ->
				alert 'upload'

	ko.applyBindings model, document.body

	# before leave
	($ window).on 'beforeunload', ->
		lang.areYouSureToLeave if editing

	# boot strap
	next()
