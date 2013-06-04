# App bootstrap
# Code to run before launching the app
cronJob = require('cron').CronJob

# Make sure you call cb() when you're finished.
module.exports.bootstrap = (cb) ->
	# cleaner job
	new cronJob '* * * * * *', ->
			return unless Image?

			# do clean expred
			console.log Image
		, null, true

	cb()
