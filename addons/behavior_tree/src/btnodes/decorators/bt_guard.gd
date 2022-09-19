class_name BTGuard
extends BTDecorator
@icon("res://addons/behavior_tree/icons/btguard.svg")

# Can lock the whole branch below itself. The lock happens either after the child ticks,
# or after any other BTNode ticks. Then it stays locked for a given time, or until another
# specified BTNode ticks. You can set all this from the inspector.
# If you don't specify a locker, the lock_if variable will be based on the child.
# If you don't specify an unlocker, the unlock_if variable is useless and only the lock_time will
# be considered, and viceversa.
# You can also choose to lock permanently or to lock on startup.
#
# A locked BTGuard will always return fail().

@export var start_locked: bool = false
@export var permanent: bool = false
@export_node_path var _locker
@export_enum("Failure", "Success", "Always") var lock_if
@export_node_path var _unlocker
@export_enum("Failure", "Success") var unlock_if
@export var lock_time: float = 0.05

var locked: bool = false

@onready var unlocker: BTNode = get_node_or_null(_unlocker)
@onready var locker: BTNode = get_node_or_null(_locker)

func _ready():
	if start_locked:
		lock()

	if locker:
		locker.connect("tick", _on_locker_tick)


# Public: Checks and sets the lock state
func _on_locker_tick(_result) -> void:
	check_lock(locker)
	set_state(locker.state)

# Public: Checks to see if the unlock condition is meet
func lock() -> void:
	locked = true

	if debug:
		print("%s locked for %s seconds" % [name, str(lock_time)])

	if permanent:
		return
	elif unlocker:
		while locked:
			var result = await unlocker.tick
			if result == bool(unlock_if):
				locked = false
	else:
		await get_tree().create_timer(lock_time, false).timeout
		locked = false

	if debug:
		print(name, "unlocked")

# Public: Checks if the lock is applied or not
#
# current_looker = Contains the node that determinces if the guard is locked or not
#
# Example
#	check_lock(BTNode.new())
func check_lock(current_locker: BTNode) -> void:
	if ((lock_if == 2 and not current_locker.running())
	or ( lock_if == 1 and current_locker.succeeded())
	or ( lock_if == 0 and current_locker.failed())):
		lock()

# Public: Runs the childrens _tick functions if not locked
#
# agent = Is the agent instance
# blackboard = Contains data that the agent has stored
#
# Example
#	_tick(Node.new(), Blackboard.new())
#		=> true
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if locked:
		return fail()
	return super(agent, blackboard)

# Public: Excutes childrens _post_tick function if not locked
#
# agent = Is the agent instance. (Unused)
# blackboard = Contains data that the agent has stored.(Unused)
# result = The result of the tick function.(Unused)
#
# Example
#	_post_tick(Node.new(), Blackboard.new(), true)
func _post_tick(_agent: Node, _blackboard: Blackboard, _result: bool) -> void:
	if not locker:
		check_lock(bt_child)


