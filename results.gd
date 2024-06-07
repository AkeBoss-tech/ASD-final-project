extends Control

var objects = []
var data = {}

func sum(numbers):
	var total = 0
	for number in numbers:
		total += number
	return total

# Method to set lap times
func set_times(car_data):
	data = car_data
	
	$UserResults.text = get_times()
	$TimeResults.text = get_sorted_times()
	$Place.text = get_fastest()
	# Update the UI or perform other actions with lap times
	print(get_leaderboard())
	print(get_user_place())

func get_times():
	var text = "Lap Times\n----------\n"

	for lap in data["laps"]:
		text += str(lap).pad_zeros(3).left(6) + "\n"
	
	return text

func get_sorted_times():
	var text = "Sorted Lap Times\n----------\n"
	
	if data["laps"].size() == 0:
		return text
	
	data["laps"].sort()
	
	for lap in data["laps"]:
		text += str(lap).pad_zeros(3).left(6) + "\n"
	
	return text

func get_fastest():
	var fastest = data["best_time"]
	return str(fastest).pad_zeros(3).left(6)

# Method to set lap times
func set_lap_times(car_objects, car_data):
	data = car_data
	objects = car_objects
	
	for car in objects:
		data[car]["average_lap"] = "n/a" if data[car]["lap"] == 0 else str(sum(data[car]["laps"]) / data[car]["lap"]).pad_zeros(3).left(6)
	
	$UserResults.text = get_leaderboard()
	$TimeResults.text = get_lap_times()
	$Place.text = get_user_place()
	# Update the UI or perform other actions with lap times
	print(get_leaderboard())
	print(get_user_place())

func get_leaderboard():
	var text = "Leaderboard\n----------\n"
	
	# Create a sorted list of cars based on laps and progress percentage
	objects.sort_custom(compare_cars)

	# Update HUD with rankings
	for i in range(objects.size()):
		var car = objects[i]
		var end = "th" if i >= 3 else ["st", "nd", "rd"][i]
		
		text += str(i + 1) + end + ". " + car.name.replace("_", " ") + "     \t" + str(round(data[car]["progress_percent"])) +"%\n"
	
	return text
	
func get_lap_times():
	var text = "Average and Fastest Times\n----------\n"
	
	# Create a sorted list of cars based on laps and progress percentage
	objects.sort_custom(compare_cars)

	# Update HUD with rankings
	for i in range(objects.size()):
		var car = objects[i]
		
		text += str(data[car]["average_lap"]) + " - " + str(data[car]["best_time"]).pad_zeros(3).left(6) + "\n"
	
	return text
	
func get_user_place():
	# Update HUD with rankings
	for i in range(objects.size()):
		var car = objects[i]
		if data[car]["player"] == true:
			var end = "th" if i >= 3 else ["st", "nd", "rd"][i]
			return str(i+1) + end

# Custom comparison function to sort cars by lap and progress percentage
func compare_cars(a, b):
	var a_data = data[a]
	var b_data = data[b]

	# Compare by laps first
	if a_data["lap"] > b_data["lap"]:
		return true
	elif a_data["lap"] < b_data["lap"]:
		return false
	
	# Compare by checkpoint progress
	if a_data["current_checkpoint_index"] > b_data["current_checkpoint_index"]:
		return true
	elif a_data["current_checkpoint_index"] < b_data["current_checkpoint_index"]:
		return false
		
	# If laps are equal, compare by progress percentage
	return a_data["progress_percent"] > b_data["progress_percent"]
