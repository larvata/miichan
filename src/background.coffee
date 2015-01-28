
do->

	# window.onload=
	console.log "background loaded"

	lastSchedules=[]
	rooms={}
	# roomIds=[2246,2319,3622,6186,41430]
	apiScheduleList="http://douyu.sashi-con.info/api/list"
	# apiRoomStatus="http://www.douyutv.com/api/client/room/"

	# schedulesTemplateHtml=$('#template-schedules').html()
	# schedulesTemplate=Handlebars.compile(schedulesTemplateHtml);

        # <div class="schedule">
        #     <div>
        #         <span class="time">{{end}}</span><span class="channel">{{begin}}</span>
        #     </div>
        #     <div>
        #         <span class="programm">{{description}}</span>
        #     </div>

        # </div>




	getSchedules=()->



		request = new XMLHttpRequest()
		request.open "GET", apiScheduleList, true
		request.onload =()->
			if request.status >= 200 and request.status < 400

				# Success!
				schedules = JSON.parse(request.responseText)


				scheduleHtml=''
				for s in schedules
					scheduleHtml+="<div class='schedule'>"
					scheduleHtml+="<div>"
					scheduleHtml+="<span class='time'>#{s.end}</span><span class='channel'>#{s.begin}</span>"
					scheduleHtml+="</div>"
					scheduleHtml+="<div>"
					scheduleHtml+="<span class='programm'>#{s.description}</span>"
					scheduleHtml+="</div>"

				# popuspWindow= chrome.extension.getViews()[0]
				# popupWindow.getElementById('scheduleList').innerHtml=scheduleHtml
				# $('.scheduleList').html(scheduleHtml)

				chrome.browserAction.setBadgeText(text:" ")
				lastSchedules=schedules
			else

			return


		# We reached our target server, but it returned an error
		request.onerror = ->


		# There was a connection error of some sort
		request.send()







	# getRoomStatus=()->
	# 	for i in roomIds
	# 		$.get "#{apiRoomStatus}#{i}",(data)->

	# 			roomStatus=JSON.parse(data)
	# 			console.log "fetched room status: #{roomStatus.data.room_id}"
	# 			_updateRoomStatus(roomStatus)

	# _updateRoomStatus=(roomStatus)->
	# 	if roomStatus.error is 0
	# 		roomId=parseInt(roomStatus.data.room_id)|0
	# 		rooms[roomId]=roomStatus.data
	# 		console.log "roomStatus updated: #{roomId}"





	getSchedules()

	# getRoomStatus()

	setInterval getSchedules,5000
