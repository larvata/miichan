
window.onload=()->

	renderSchedule()

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
