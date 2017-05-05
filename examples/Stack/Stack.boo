namespace Specter.Examples.Stack

import System


class Stack:
	
	items = []
	
	def Push(obj as int):
		items.Add(obj)
		
	def Pop() as int:
		if items.Count == 0:
			raise StackUnderflowException()
		else:
			obj = items[items.Count - 1]
			items.RemoveAt(items.Count - 1)
			return obj
		
	Top as int:
		get:
			if items.Count == 0:
				raise StackUnderflowException()
			else:
				return items[items.Count - 1]


class StackUnderflowException(Exception):
	pass
