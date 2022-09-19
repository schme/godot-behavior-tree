class_name BTRepeatUntil
extends BTDecorator
@icon("res://addons/behavior_tree/icons/btrepeatuntil.svg")

# Repeats until specified state is returned, then sets state to child state

@export_enum("Failure", "Success") var until_what
@export var frequency: float

@onready var expected_result = bool(until_what)

# Public: Repeatedly calls the childrens _tick functions until the desired result is returned
#
# agent = Is the agent instance
# blackboard = Contains data that the agent has stored
#
# Example
#	_tick(Node.new(), Blackboard.new())
#		=> true
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = not expected_result

	while result != expected_result:
		result = bt_child.do_tick(agent, blackboard)

		await get_tree().create_timer(frequency, false).timeout

	return set_state(bt_child.state)
