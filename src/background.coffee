schedules=[]
scheduleChanged=false
lastSchedules=[]

apiScheduleList="http://douyu.sashi-con.info/api/list"

setBadge=(text)->
	chrome.browserAction.setBadgeText(text:text)


getSchedules=()->
	request = new XMLHttpRequest()
	request.open "GET", apiScheduleList, true
	request.onload=()->
		if request.status >= 200 and request.status < 400

			# Success!
			schedules = JSON.parse(request.responseText)

			if JSON.stringify(schedules) is JSON.stringify(lastSchedules)

			else
				setBadge('!')


			lastSchedules=schedules
		else

		return

	# We reached our target server, but it returned an error
	request.onerror=()->

	# There was a connection error of some sort
	request.send()

do->

	# window.onload=
	console.log "background loaded"



	getSchedules()

	setInterval getSchedules,5000
