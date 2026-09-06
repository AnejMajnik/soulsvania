extends Composite
class_name Selector

func tick(delta: float) -> Status:
	var children = get_bt_children()
	for i in range(current_child_index, children.size()):
		var result = children[i].tick(delta)
		if result == Status.RUNNING:
			current_child_index = i
			return Status.RUNNING
		if result == Status.SUCCESS:
			current_child_index = 0
			return Status.SUCCESS
	current_child_index = 0
	return Status.FAILURE
