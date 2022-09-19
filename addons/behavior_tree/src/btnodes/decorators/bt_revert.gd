class_name BTRevert
extends BTDecorator
@icon("res://addons/behavior_tree/icons/btrevert.svg")

# Succeeds if the child fails and viceversa.

# Public: Returns the opposite result the child's _tick function provided
#
# agent = Is the agent instance
# blackboard = Contains data that the agent has stored
#
# Example
#	_tick(Node.new(), Blackboard.new())
#		=> true
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.do_tick(agent, blackboard)
	
	if bt_child.succeeded():
		return fail()
	return succeed()

