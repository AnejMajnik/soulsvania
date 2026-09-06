extends Node
class_name BTNode

enum Status { SUCCESS, FAILURE, RUNNING }

func tick(delta: float) -> Status:
	return Status.FAILURE
