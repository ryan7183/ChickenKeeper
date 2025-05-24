extends Node

signal item_purchased

const water_cost = 10
const dirt_cost = 10
const grass_cost = 50
const fence_cost = 20

var money:int = 1000

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
