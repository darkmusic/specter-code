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
import System.Runtime.CompilerServices;

[Extension]
static def Must(x as ICallable, asserter as IAsserter):
	return CallableMust(x, asserter)

class CallableMust(ICallableMust):

	private _asserter as IAsserter
	private _runner as ICallable

	def constructor(runner as ICallable, [required]asserter as IAsserter):
		_asserter = asserter
		_runner = runner

	Not:
		get:
			return CallableMust(_runner, _asserter.Inverted)

	def Throw():
		thrown = false

		try:
			_runner()
		except:
			thrown = true

		_asserter.Assert(thrown, "no exception thrown", typeof(Exception))

	def Throw([required]type as Type):
		assert typeof(Exception).IsAssignableFrom(type), "Argument for Throw must be an Exception"
		
		thrown = false
		try:
			_runner()
		except ex as Exception:
			if type == ex.GetType():
				thrown = true
			else:
				if _asserter isa SpecterAsserter:
					_asserter.Assert(false, ex, type)
				else:
					raise ex
				return
		
		_asserter.Assert(thrown, "no exception thrown", type)

	def ThrowKindOf([required]type as Type):
		assert typeof(Exception).IsAssignableFrom(type), "Argument for ThrowKindOf must be an Exception"

		thrown = false
		try:
			_runner()
		except ex as Exception:
			if type.IsAssignableFrom(ex.GetType()):
				thrown = true
			else:
				if _asserter isa SpecterAsserter:
					_asserter.Assert(false, ex, type)
				else:
					raise ex
				return

		_asserter.Assert(thrown, "no exception thrown", type)

