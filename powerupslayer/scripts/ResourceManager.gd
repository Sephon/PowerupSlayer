extends Node

signal iron_scrap_changed(new_amount: int)

var iron_scrap: int = 0

func add_iron_scrap(amount: int) -> void:
	iron_scrap += amount
	iron_scrap_changed.emit(iron_scrap)

func get_iron_scrap() -> int:
	return iron_scrap 