class_name BTSequence
extends BTComposite
@icon("res://addons/behavior_tree/icons/btsequence.svg")

# Ticks its children as long as ALL of them are successful.
# Successful if ALL the children are successful.
# Fails if ANY of the children fails.

# Public: Returns true once all the childrens _tick functions are completed
#
# agent = Is the agent instance
# blackboard = Contains data that the agent has stored
#
# Example
#	_tick(Node.new(), Blackboard.new())
#		=> true
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result

	for c in children:
		bt_child = c

		result = await bt_child.do_tick(agent, blackboard)

		if bt_child.failed():
			return fail()

	return succeed()
