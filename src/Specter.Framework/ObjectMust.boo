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
static def Must(x as object, asserter as IAsserter):
	return ObjectMust(x, asserter)

class ObjectMust(IObjectMust, IEquatableMust, IComparableMust, ISatisfiableMust):

	private _asserter as IAsserter
	private _value as object

	[AutoDelegate(IEquatableMust)]
	private _equatableMust as EquatableMust
	[AutoDelegate(IComparableMust)]
	private _comparableMust as ComparableMust
	[AutoDelegate(ISatisfiableMust)]
	private _satisfiableMust as ISatisfiableMust

	def constructor(value as object, [required]asserter as IAsserter):
		_asserter = asserter
		_value = value

		_equatableMust = EquatableMust(value, asserter)
		try:
			_comparableMust = ComparableMust(value, asserter)
		except:
			pass

	Not:
		get:
			return ObjectMust(_value, _asserter.Inverted)

	protected Asserter:
		get:
			return _asserter

	def BeNull():
		_asserter.Assert(_value is null)

	def ReferentiallyEqual(expected as object):
		_asserter.Assert(object.ReferenceEquals(_value, expected))

	def BeInstanceOf([required]expectedType as Type):
		_asserter.Assert(_value.GetType() == expectedType, _value.GetType(), "instance of ${expectedType}")

	def BeKindOf([required]expectedType as Type):
		_asserter.Assert(expectedType.IsAssignableFrom(_value.GetType()), _value.GetType(), "kind of ${expectedType}")

	static def op_Equality(actual as ObjectMust, expected as object):
		actual._equatableMust.Equal(expected)

	static def op_Inequality(actual as ObjectMust, expected as object):
		actual._equatableMust.Not.Equal(expected)

	static def op_LessThan(actual as ObjectMust, expected as object):
		actual._comparableMust.BeLessThan(expected)

	static def op_GreaterThan(actual as ObjectMust, expected as object):
		actual._comparableMust.BeGreaterThan(expected)

	static def op_LessThanOrEqual(actual as ObjectMust, expected as object):
		actual._comparableMust.BeLessThanOrEqual(expected)

	static def op_GreaterThanOrEqual(actual as ObjectMust, expected as object):
		actual._comparableMust.BeGreaterThanOrEqual(expected)

