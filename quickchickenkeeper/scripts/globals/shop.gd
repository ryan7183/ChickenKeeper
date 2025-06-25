extends Node

signal item_purchased
signal item_sold
signal money_changed

const water_cost = 10
const dirt_cost = 10
const grass_cost = 50
const fence_cost = 20

const chicken_sell_value:int = 30
const egg_sell_value:int = 40

var money:int = 5000
var item_over_sell_box:bool = false

func get_save_data()->Dictionary:
	return {
		"money": money,
	}

func apply_save_data(data:Dictionary)->void:
	money = data["money"]
	money_changed.emit()
	pass


func buy_water()->bool:
	if money - water_cost >=0:
		money -= water_cost
		item_purchased.emit()
		money_changed.emit()
		return true
	return false

func buy_dirt()->bool:
	if money - dirt_cost >=0:
		money -= dirt_cost
		item_purchased.emit()
		money_changed.emit()
		return true
	return false

func buy_grass()->bool:
	if money - grass_cost >=0:
		money -= grass_cost
		item_purchased.emit()
		money_changed.emit()
		return true
	return false

func buy_fence()->bool:
	if money - fence_cost >=0:
		money -= fence_cost
		item_purchased.emit()
		money_changed.emit()
		return true
	return false

func sell_egg()->void:
	money += egg_sell_value
	item_sold.emit()
	money_changed.emit()

func sell_chicken()->void:
	money+=chicken_sell_value
	item_sold.emit()
	money_changed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("AddMoney") and HelperFunctions.is_debug():
		money+= 1000
		money_changed.emit()
		pass
