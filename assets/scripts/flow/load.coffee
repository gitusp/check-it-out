define [], ->
	(items, callback) ->
		# get image
		[image] = for datam in items
			datam if /image\/.+/.test datam.type
		return false unless image?

		# read image
		reader = new FileReader
		reader.onload = (e) ->
			callback e.target.result

		file = if image.getAsFile? then image.getAsFile() else image
		reader.readAsDataURL file
		true
		