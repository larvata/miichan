
window.onload=()->

	renderSchedule()
	renderRoom()

newTab=(room_id)->
	url="http://www.douyutv.com/"+room_id
	chrome.tabs.create(url:url)


renderSchedule=()->

	schedules=chrome.extension.getBackgroundPage().schedules

	scheduleHtml=''
	for s in schedules
		scheduleHtml+="<div class='schedule'>"
		scheduleHtml+="<div>"
		scheduleHtml+="<span class='time'>#{s.end}</span><span class='channel'>#{s.begin}</span>"
		scheduleHtml+="</div>"
		scheduleHtml+="<div>"
		scheduleHtml+="<span class='programm'>#{s.description}</span>"
		scheduleHtml+="</div>"
		scheduleHtml+="</div>"

	document.getElementById('scheduleList').innerHTML=scheduleHtml

	chrome.extension.getBackgroundPage().setBadge('')


renderRoom=()->

	rooms=chrome.extension.getBackgroundPage().rooms

	roomHtml=''

	for r in rooms
		roomHtml+="<li class='layout-item-module layout-item-module-base'>"
		roomHtml+="<button title='关注人数:#{r.fans}' class='open-tab-button pure-button #{if (r.show_status is 2) then '' else 'button-success'}' data-room-id='#{r.room_id}'>#{r.room_name}</button>"
		roomHtml+="</li>"

	document.getElementById('roomList').innerHTML=roomHtml


	btns=document.getElementsByClassName('open-tab-button')

	for b in btns
		b.addEventListener 'click',()->
			url="http://www.douyutv.com/"+@attributes['data-room-id'].value
			chrome.tabs.create(url:url)



