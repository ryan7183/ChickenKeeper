extends Node

signal item_purchased
signal item_sold

const water_cost = 10
const dirt_cost = 10
const grass_cost = 50
const fence_cost = 20

const chicken_sell_value:int = 25
const egg_sell_value:int = 30

var money:int = 5000
var item_over_sell_box:bool = false

func buy_water()->bool:
	if money - water_cost >=0:
		money -= water_cost
		item_purchased.emit()
		return true
	return false

func buy_dirt()->bool:
	if money - dirt_cost >=0:
		money -= dirt_cost
		item_purchased.emit()
		return true
	return false

func buy_grass()->bool:
	if money - grass_cost >=0:
		money -= grass_cost
		item_purchased.emit()
		return true
	return false

func buy_fence()->bool:
	if money - fence_cost >=0:
		money -= fence_cost
		item_purchased.emit()
		return true
	return false

func sell_egg()->void:
	money += egg_sell_value
	item_sold.emit()

func sell_chicken()->void:
	money+=chicken_sell_value
	item_sold.emit()
