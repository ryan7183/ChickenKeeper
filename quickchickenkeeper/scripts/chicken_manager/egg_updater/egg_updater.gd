class_name EggUpdater extends Node

func update_eggs(chicken_positions:Array[Vector2],\
 chicken_satisfaction_time:Array[float],\
 egg_positions:Array[Vector2],\
 egg_time_till_hatch:Array[float])->Dictionary:
	
	var result:Dictionary = hatch_eggs(egg_positions, egg_time_till_hatch)
	var new_chickens:Array[Vector2] = result["new_chickens"]
	egg_positions = result["egg_positions"]
	egg_time_till_hatch = result["egg_time_till_hatch"]
	
	result = lay_eggs(chicken_positions, chicken_satisfaction_time)
	chicken_satisfaction_time = result["chicken_satisfaction_time"]
	return {
		"new_chicken_positions":new_chickens,
		"updated_satisfaction_time":chicken_satisfaction_time,
		"updated_egg_position_list":egg_positions,
		"updated_time_tile_hatch":egg_time_till_hatch,
		"laid_eggs":result["laid_eggs"]
	}

func hatch_eggs(egg_positions:Array[Vector2],egg_time_till_hatch:Array[float])->Dictionary:
	var new_chickens:Array[Vector2] = []
	for i:int in range(egg_positions.size()-1,-1,-1):
		if egg_time_till_hatch[i]<=0:
			new_chickens.append(egg_positions[i])
			egg_time_till_hatch.remove_at(i)
			egg_positions.remove_at(i)
		else:
			egg_time_till_hatch[i]-=1
			pass
		pass
	return {"new_chickens":new_chickens,
			"egg_positions":egg_positions,
			"egg_time_till_hatch":egg_time_till_hatch}

func lay_eggs(chicken_positions:Array[Vector2], chicken_satisfaction_time:Array[float])->Dictionary:
	var layed_eggs:Array[Vector2] = []
	for i:int in range(chicken_satisfaction_time.size()):
		if chicken_satisfaction_time[i]>=50:
			var near_by_index:int = near_by_chicken(chicken_positions[i], chicken_positions)
			if near_by_index != -1:
				chicken_satisfaction_time[i]= 0
				layed_eggs.append(chicken_positions[i])
		pass
	
	return {
		"laid_eggs":layed_eggs,
		"chicken_satisfaction_time":chicken_satisfaction_time,
	}

func near_by_chicken(pos:Vector2, chicken_positions:Array[Vector2])->int:
	var near_by:int = -1
	
	for i:int in chicken_positions.size():
		if chicken_positions[i] != pos and chicken_positions[i].distance_to(pos)<100:
			near_by = i
			break
		pass
	return near_by
