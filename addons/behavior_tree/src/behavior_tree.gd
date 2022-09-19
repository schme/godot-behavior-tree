class_name BehaviorTree
extends Node
@icon("res://addons/behavior_tree/icons/bt.svg")

# This is your main node. Put one of these at the root of the scene and start adding BTNodes.
# A Behavior Tree only accepts ONE entry point (so one child).

@export var is_active: bool = false
@export_node_path var _blackboard
@export_node_path var _agent
@export_enum("Idle", "Physics") var sync_mode
@export var debug: bool = false

var tick_result

@onready var agent = get_node(_agent) as Node
@onready var blackboard = get_node(_blackboard) as Blackboard
@onready var bt_root = get_child(0) as BTNode

func _ready() -> void:
	assert(get_child_count() == 1, "A Behavior Tree can only have one entry point.")
	bt_root.propagate_call("connect", ["abort_tree", self.abort])
	start()

func _process(_delta: float) -> void:
	if not is_active:
		set_process(false)
		return

	if debug:
		print()

	tick_result = await bt_root.do_tick(agent, blackboard)

func _physics_process(_delta: float) -> void:
	if not is_active:
		set_physics_process(false)
		return

	if debug:
		print()

	tick_result = await bt_root.do_tick(agent, blackboard)

# Internal: Set up if we are using process or physics_process for the behavior tree
func start() -> void:
	if not is_active:
		return

	match sync_mode:
		0:
			set_physics_process(false)
			set_process(true)
		1:
			set_process(false)
			set_physics_process(true)

# Public: Set the tree to inactive when a abort_tree signal is sent from bt_root
func abort() -> void:
	is_active = false
