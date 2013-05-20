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
						# get image
						[image] = for datam in e.originalEvent.clipboardData.items
							datam if /image\/.+/.test datam.type
						return alert lang.noImagesInClipBoard unless image?

						# read image
						reader = new FileReader
						reader.onload = (e) ->
							isDataURL = true
							model.imageSource e.target.result
							next()
						reader.readAsDataURL image.getAsFile()

				 # TODO: bind drop
				 # if model.canDropImage
				 	# TODO: do

			exit: ->
				($ document).off 'paste'
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
			# TODO detection
			@canPasteImage = true
			@canDropImage = true

			# 
			@imageSource = ko.observable '/images/spacer.gif'
			@state = ko.observable 'portal'
			@upload = (e) ->
				alert 'upload'

	ko.applyBindings model, document.body

	# TODO: before leave
	($ window).on 'beforeunload', ->
		return lang.areYouSureToLeave if editing

	# boot strap
	next()
