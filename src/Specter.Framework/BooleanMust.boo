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
import Specter.Util
import System.Runtime.CompilerServices;

[Extension]
def Must(b as bool, asserter as IAsserter):
	return BooleanMust(b, asserter)

class BooleanMust(IComparableMust, IEquatableMust, ISatisfiableMust):

	private _value as bool
	private _asserter as IAsserter

	[AutoDelegate(IComparableMust)]
	private _comparableMust as IComparableMust
	[AutoDelegate(IEquatableMust)]
	private _equatableMust as IEquatableMust
	[AutoDelegate(ISatisfiableMust)]
	private _satisfiableMust as ISatisfiableMust

	def constructor(value as bool, asserter as IAsserter):
		_value = value
		_asserter = asserter as IAsserter
		
		_satisfiableMust = SatisfiableMust(value, asserter)
		_equatableMust = EquatableMust(value, asserter)
		_comparableMust = ComparableMust(value, asserter)

	Not:
		get:
			return BooleanMust(_value, _asserter.Inverted)

	def BeTrue():
		_asserter.Assert(_value, _value, true)

	def BeFalse():
		_asserter.Assert(not _value, _value, false)

