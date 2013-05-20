require [], ->
	step = 0
	steps = [
		{
			enter: ->
				# bind paste
				($ document).on 'paste', (e) ->
					# TODO: alert for legacy

					# get image
					[image] = for datam in e.clipboardData.items
						if /image\/.+/.test datam.type then datam else false
					return alert 'no images found' unless image?

					# read image
					reader = new FileReader
					reader.onload = (e) ->
						console.log evt.target.result
					reader.readAsDataURL image.getAsFile()

				 # TODO: bind drop

			exit: ->
				($ document).off 'click'
		}
		{
			enter: ->
				viewModel.state 'editor'
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

	viewModel = new class
		constructor: ->
			@state = ko.observable 'portal'
			@upload = (e) ->
				alert 'upload'

	ko.applyBindings viewModel, document.body

	# boot strap
	next()
