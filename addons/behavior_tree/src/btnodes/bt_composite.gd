class_name BTComposite
extends BTNode
@icon("res://addons/behavior_tree/icons/btcomposite.svg")

# Executes every child, waiting for completion. Always succeeds.
#
# Can be used to create custom flows inside a group of children BTNodes.
# Most of your needs are probably satisfied by the ones I already provided
# to you, but you may have some specific flow in your game. In that case,
# you can extend this script and define it yourself.

var bt_child: BTNode # Used to iterate over children

@onready var children: Array = get_children() as Array

func _ready():
	assert(get_child_count() > 1, "A BTComposite must have more than one child.")

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

	return succeed()
