schedules=[]
scheduleChanged=false
lastSchedules=[]

rooms=[]
roomsStatus={}
roomsShowTime={}

scheduleNotificationId="6666"

# apiDomain="127.0.0.1:3434"
apiDomain="live.sashi.co"

apiScheduleList="http://#{apiDomain}/api/list"
apiScheduleRoom="http://#{apiDomain}/api/room"
apiSnap="http://#{apiDomain}/snap"
apiAvatar="http://#{apiDomain}/avatar"



getBase64Image=(img)->

	canvas=document.createElement("canvas")
	canvas.width=img.width
	canvas.height=img.height

	ctx=canvas.getContext("2d")
	ctx.clearRect 0,0,canvas.width,canvas.height
	ctx.drawImage img,0,0,canvas.width,canvas.height

	return canvas.toDataURL("image/jpg")


setBadge=(text)->
	chrome.browserAction.setBadgeText(text:text)

showScheduleNotification=()->
	items=schedules.map (s)->
		start=s.end.split('～')[0]
		{title:"#{s.begin} #{start}",message:s.description}

	chrome.notifications.clear scheduleNotificationId,()->
		options=
			type:"list"
			iconUrl:'images/icon128.png'
			title: '节目单更新'
			message: '<null>'
			items:items
		chrome.notifications.create scheduleNotificationId,options,(notificationId)->


showRoomNotification=(room)->

	img=new Image()
	img.crossOrigin = 'anonymous'
	# img.src=room.live_snapshot.replace("http://staticlive.douyutv.com/upload/web_pic",apiSnap)
	switch room.live_provider
		when 'douyu'
			img.src=apiSnap+'/douyu'+room.live_snapshot
		when 'zhanqi'
			img.src=apiSnap+'/zhanqi'+room.live_snapshot
	img.onload=(data)->

		imgData=getBase64Image(img)
		imgAvatar=new Image()
		imgAvatar.crossOrigin='anonymous'
		switch room.live_provider
			when 'douyu'
				imgAvatar.src=apiAvatar+'/douyu'+room.owner_avatar
			when 'zhanqi'
				imgAvatar.src=apiAvatar+'/zhanqi'+room.owner_avatar			
		
		

		imgAvatar.onload=(data)->

			avatarData=getBase64Image(imgAvatar)
			d=new Date(room.show_time*1000)
			dn=new Date()
			diff=dn-d
			minutes=Math.round(diff/60000)

			# formattedTime="#{d.getFullYear()}/#{d.getMonth()+1}/#{d.getDay()+1} #{d.getHours()}:#{('0'+d.getMinutes()).substr(d.getMinutes().toString().length-1)}"
			message ="已播#{minutes}分钟 "
			message += "#{room.show_details}"

			options=
				type:"image"
				iconUrl: avatarData
				title: "#{room.room_name}"
				imageUrl:imgData
				message: message

			chrome.notifications.create(
				room.room_id.toString()
				options
				(notificationId)->
			)


clearRoomNotification=(room)->
	chrome.notifications.clear room.room_id.toString(),()->

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
				showScheduleNotification()

			lastSchedules=schedules
		else

		return
	request.onerror=()->

	request.send()
	setTimeout getSchedules,120000

getRooms=()->
	request=new XMLHttpRequest()
	request.open "GET", apiScheduleRoom,true
	request.onload=()->
		if request.status>=200 and request.status<400
			rooms=JSON.parse(request.responseText)

			for r in rooms

				if r.show_status == 1
					if roomsStatus[r.room_id] is r.show_status
						if r.show_time != roomsShowTime[r.room_id]
							clearRoomNotification(r)
							showRoomNotification(r)
					else
						showRoomNotification(r)
				else
					# r.show_status == 2
					clearRoomNotification(r)

				roomsStatus[r.room_id]=r.show_status
				roomsShowTime[r.room_id]=r.show_time

		return
	request.onerror=()->

	request.send()

	setTimeout getRooms,120000


do->
	getSchedules()
	getRooms()

