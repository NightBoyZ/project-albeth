extends Label

func _ready():
	# Call the update_time function every second
	set_process(true)
	update_time()

func _process(delta):
	update_time()

func update_time():
	var time_now = Time.get_time_dict_from_system()
	var am_pm = "AM" if time_now.hour < 12 else "PM"
	var hour = time_now.hour % 12
	hour = hour if hour != 0 else 12
	var time_text = "%02d:%02d:%02d %s" % [hour, time_now.minute, time_now.second, am_pm]
	text = time_text
