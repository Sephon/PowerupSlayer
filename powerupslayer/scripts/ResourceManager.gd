extends Node

signal iron_scrap_changed(new_amount: int)

const MAX_IRON_SCRAP := 100
var iron_scrap: int = 0

func add_iron_scrap(amount: int) -> void:
	var new_amount = min(iron_scrap + amount, MAX_IRON_SCRAP)
	if new_amount != iron_scrap:
		iron_scrap = new_amount
		iron_scrap_changed.emit(iron_scrap)

func get_iron_scrap() -> int:
	return iron_scrap

func has_iron_scrap(amount: int) -> bool:
	return iron_scrap >= amount

func spend_iron_scrap(amount: int) -> bool:
	if iron_scrap >= amount:
		iron_scrap -= amount
		iron_scrap_changed.emit(iron_scrap)
		return true
	return false 
