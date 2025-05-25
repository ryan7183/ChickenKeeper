class_name EggUpdater extends Node

func update_eggs(chicken_positions:Array[Vector2],\
 chicken_satisfaction_time:Array[float],\
 egg_positions:Array[Vector2],\
 egg_time_till_hatch:Array[float],\
 chicken_color:Array[int],\
 chicken_type:Array[int],
 egg_color:Array[int],\
 egg_type:Array[int],)->Dictionary:
	
	var result:Dictionary = hatch_eggs(egg_positions, egg_time_till_hatch, egg_color, egg_type)
	var new_chickens:Array[Dictionary] = result["new_chickens"]
	egg_positions = result["egg_positions"]
	egg_time_till_hatch = result["egg_time_till_hatch"]
	
	result = lay_eggs(chicken_positions, chicken_satisfaction_time, chicken_color, chicken_type)
	chicken_satisfaction_time = result["chicken_satisfaction_time"]
	return {
		"new_chicken_positions":new_chickens,
		"updated_satisfaction_time":chicken_satisfaction_time,
		"updated_egg_position_list":egg_positions,
		"updated_time_tile_hatch":egg_time_till_hatch,
		"laid_eggs":result["laid_eggs"]
	}

func hatch_eggs(egg_positions:Array[Vector2],egg_time_till_hatch:Array[float], hatchling_color:Array[int], hatchling_type:Array[int])->Dictionary:
	var new_chickens:Array[Dictionary] = []
	for i:int in range(egg_positions.size()-1,-1,-1):
		if egg_time_till_hatch[i]<=0:
			var chicken_data:Dictionary = {
				"position":egg_positions[i],
				"color":hatchling_color[i],
				"type":hatchling_type[i],
				"egg_time_till_hatch": 300,
			}
			new_chickens.append(chicken_data)
			egg_time_till_hatch.remove_at(i)
			egg_positions.remove_at(i)
			hatchling_color.remove_at(i)
			hatchling_type.remove_at(i)
		else:
			egg_time_till_hatch[i]-=1
			pass
		pass
	return {"new_chickens":new_chickens,
			"egg_positions":egg_positions,
			"egg_time_till_hatch":egg_time_till_hatch}

func lay_eggs(chicken_positions:Array[Vector2], chicken_satisfaction_time:Array[float], chicken_color:Array[int], chicken_type:Array[int])->Dictionary:
	var laid_eggs:Array[Dictionary] = []
	for i:int in range(chicken_satisfaction_time.size()):
		if chicken_satisfaction_time[i]>=50:
			var near_by_index:int = near_by_chicken(chicken_positions[i], chicken_positions)
			if near_by_index != -1:
				chicken_satisfaction_time[i]= 0
				var egg_data:Dictionary = {
					"egg_position": chicken_positions[i],
					"egg_hatchling_color": mutate_color(chicken_color[i],chicken_color[near_by_index]),
					"egg_hatchling_type": mutate_type(chicken_type[i] if randf()<=0.5 else chicken_type[near_by_index]),
					"egg_time_till_hatch": 300,
				}
				laid_eggs.append(egg_data)
		pass
	
	return {
		"laid_eggs":laid_eggs,
		"chicken_satisfaction_time":chicken_satisfaction_time,
	}

func mutate_color(par1_color:int, par2_color:int)->int:
	var mix_chance:float = randf()
	var final_color:int = par1_color
	if mix_chance<0.01:
		final_color = mix_color(par1_color, par2_color) 
	else:
		final_color = par1_color if randf()<0.6 else par2_color
		
	var red_component:int = final_color%1000
	final_color = final_color/1000
	var green_component:int = final_color%1000
	final_color = final_color/1000
	var blue_component:int = final_color%1000
	var red_chance:float = randf()
	var red_mutation:int = 5 if red_chance<(1.0/6.0) else -5 if red_chance<(2.0/6.0) else 0
	var green_chance:float = randf()
	var green_mutation:int = 5 if green_chance<(1.0/6.0) else -5 if green_chance<(2.0/6.0) else 0
	var blue_chance:float = randf()
	var blue_mutation:int = 5 if blue_chance<(1.0/6.0) else -5 if blue_chance<(2.0/6.0) else 0
	red_component = clamp(red_component+red_mutation,0,100)
	blue_component = clamp(blue_component+blue_mutation,0,100)
	green_component = clamp(green_component+green_mutation,0,100)
	final_color = red_component + green_component*1000 + blue_component *1000*1000
	return final_color

func mix_color(par1_color:int,par2_color:int)->int:
	var red_component:int = par1_color%1000 if randf()<=0.5 else par2_color%1000
	par1_color = par1_color/1000
	par2_color = par2_color/1000
	var green_component:int = par1_color%1000 if randf()<=0.5 else par2_color%1000
	par1_color = par1_color/1000
	par2_color = par2_color/1000
	var blue_component:int = par1_color%1000 if randf()<=0.5 else par2_color%1000
	var red_chance:float = randf()
	var red_mutation:int = 1 if red_chance<(1.0/6.0) else -1 if red_chance<(2.0/6.0) else 0
	var green_chance:float = randf()
	var green_mutation:int = 1 if green_chance<(1.0/6.0) else -1 if green_chance<(2.0/6.0) else 0
	var blue_chance:float = randf()
	var blue_mutation:int = 1 if blue_chance<(1.0/6.0) else -1 if blue_chance<(2.0/6.0) else 0
	
	red_component = clamp(red_component+red_mutation,0,100)
	blue_component = clamp(blue_component+blue_mutation,0,100)
	green_component = clamp(green_component+green_mutation,0,100)
	var final_color:int = red_component + green_component*1000 + blue_component *1000*1000
	return final_color

func mutate_type(type:int)->int:
	var chance:float = randf()
	if chance<0.1:
		if type==0:
			type=1
		else:
			type = 0
	return type

func near_by_chicken(pos:Vector2, chicken_positions:Array[Vector2])->int:
	var near_by:int = -1
	
	for i:int in chicken_positions.size():
		if chicken_positions[i] != pos and chicken_positions[i].distance_to(pos)<100:
			near_by = i
			break
		pass
	return near_by
