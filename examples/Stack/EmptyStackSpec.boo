namespace Specter.Examples.Stack

import System
import Specter.Framework


context "An empty stack":

	stack as Stack

	setup:
		stack = Stack()

	specify { stack.Push(42) }.Must.Not.Throw()

	# -- Long version
	# specify "Must complain when sent top":
	#	{ stack.Top }.Must.Throw(typeof(StackUnderflowException))
	# -- Shorthand version:
	specify { stack.Top }.Must.Throw(typeof(StackUnderflowException))

	specify { stack.Pop() }.Must.Throw(typeof(StackUnderflowException))
