namespace Examples

import System
import Specter.Framework


[Extension]
def Must(x as Foo, message as string):
	return FooMust(x, CreateAsserter(message))

class Foo:
	pass
	
class FooMust(ObjectMust):
	
	def constructor(value as Foo, asserter as IAsserter):
		super(value, asserter)
		
	def BeCool():
		Asserter.Assert(true)

