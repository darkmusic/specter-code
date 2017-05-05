namespace Specter.Examples.Stack

import System
import Specter.Framework

context "A stack with one item":
	stack as Stack

	setup:
		stack = Stack()
		stack.Push(3)

	specify { stack.Push(42) }.Must.Not.Throw()

	specify stack.Top.Must == 3

	specify "Must not remove top when sent top":
		stack.Top.Must == 3
		stack.Top.Must == 3

	specify stack.Pop().Must == 3

	specify "Must remove top when sent pop":
		stack.Pop().Must == 3
		{ stack.Pop() }.Must.Throw(typeof(StackUnderflowException))

  


