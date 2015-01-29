schedules=[]
scheduleChanged=false
lastSchedules=[]

apiScheduleList="http://douyu.sashi-con.info/api/list"

setBadge=(text)->
	chrome.browserAction.setBadgeText(text:text)

showNotification=()->
	# notification=webkitNotifications.createNotification('images/icon64.png','hello','body')
	items=schedules.map (s)->
		start=s.end.split('～')[0]
		{title:"#{s.begin} #{start}",message:s.description}

	options=
		type:"list"
		iconUrl:'images/icon64.png'
		title: 'douyu schedule updated'
		message: 'heheheh '
		items:items


	chrome.notifications.create(
		"6666"
		options
		(notificationId)->
	)




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
				showNotification()


			lastSchedules=schedules
		else

		return

	# We reached our target server, but it returned an error
	request.onerror=()->

	# There was a connection error of some sort
	request.send()

do->
	console.log "background loaded"
	# getSchedules()
	setInterval getSchedules,5000
