#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Framework

import System
import System.Collections
import Specter.Util
import System.Runtime.CompilerServices;

[Extension]
def Must(x as IEnumerable, asserter as IAsserter):
	return EnumerableMust(x, asserter)

class EnumerableMust(IEnumerableMust, IObjectMust, ISatisfiableMust):

	private _items as IEnumerable
	private _asserter as IAsserter

	[AutoDelegate(IObjectMust)]
	private _objectMust as IObjectMust
	[AutoDelegate(ISatisfiableMust)]
	private _satisfiableMust as ISatisfiableMust

	def constructor(items as IEnumerable, asserter as IAsserter):
		_items = items
		_asserter = asserter
		
		_objectMust = ObjectMust(items, asserter)
		_satisfiableMust = SatisfiableMust(items, asserter)

	virtual Not:
		get:
			return EnumerableMust(_items, _asserter.Inverted)

	virtual def Contain(item as object):
		for obj in _items:
			if obj == item:
				_asserter.Assert(true)
				return

		_asserter.Assert(false)

	virtual def BeEmpty():
		# If we can "move next" to the first item
		# then fail since it's not empty
		if _items.GetEnumerator().MoveNext():
			_asserter.Assert(false)
			return

		_asserter.Assert(true)

	def AllSatisfy(predicate as Predicate of object):
		for obj in _items:
			if not predicate(obj):
				_asserter.Assert(false)
				return

		_asserter.Assert(true)

	def SomeSatisfy(predicate as Predicate of object):
		some = false
		for obj in _items:
			if predicate(obj):
				some = true
		_asserter.Assert(some)

	def Equal(expected as IEnumerable):
		if (_items is null) and (expected is null):
			_asserter.Assert(false)
			return

		if (_items is null) ^ (expected is null):
			_asserter.Assert(false)
			return
			
		e1 = _items.GetEnumerator()
		e2 = expected.GetEnumerator()
		got1 = true
		got2 = true

		while got1 and got2:
			got1 = e1.MoveNext()
			got2 = e2.MoveNext()
			if got1 and got2:
				if e1.Current != e2.Current:
					_asserter.Assert(false)

		if got1 ^ got2:
			# different number of items
			_asserter.Assert(false)
		else:
			_asserter.Assert(true)

	protected Asserter:
		get:
			return _asserter

