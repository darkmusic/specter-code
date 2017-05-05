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

[Extension]
def Must(x as string, asserter as IAsserter):
	return StringMust(x, false, asserter)

class StringMust(IComparableMust, IObjectMust, IEquatableMust, ISatisfiableMust):

	private _value as string
	private _asserter as IAsserter
	private _ignoreCase as bool

	[AutoDelegate(ISatisfiableMust)]
	[AutoDelegate(IEquatableMust)]
	[AutoDelegate(IObjectMust)]
	private _objectMust as IObjectMust
	[AutoDelegate(IComparableMust)]
	private _comparableMust as IComparableMust

	def constructor(value as string, ignoreCase as bool, [required]asserter as IAsserter):
		_value = value
		_ignoreCase = ignoreCase
		_asserter = asserter

		_objectMust = ObjectMust(value, asserter)
		_comparableMust = ComparableMust(value, asserter)

	Not:
		get:
			return StringMust(_value, _ignoreCase, _asserter.Inverted)

	IgnoringCase as StringMust:
		get:
			return StringMust(_value, true, _asserter)

	def Equal(expected as string):
		if _ignoreCase:
			_asserter.Assert(_value.Equals(expected, StringComparison.CurrentCultureIgnoreCase), _value, expected)
		else:
			_asserter.Assert(_value.Equals(expected), _value, expected)

	def BeEmpty():
		_asserter.Assert(_value.Length == 0, "string with length of ${_value.Length} : ${_value}", "empty string")

	def StartWith([required]start as string):
		_asserter.Assert(_value.StartsWith(start, _ignoreCase, null))

	def EndWith([required]end as string):
		_asserter.Assert(_value.EndsWith(end, _ignoreCase, null))

	def Contain([required]substring as string):
		if _ignoreCase:
			_asserter.Assert(_value.IndexOf(substring, StringComparison.CurrentCultureIgnoreCase) > -1)
		else:
			_asserter.Assert(_value.IndexOf(substring) > -1)

	def Match([required]expr as regex):
		_asserter.Assert(expr.IsMatch(_value))

	Be:
		get:
			return self

	static def op_Match(must as StringMust, expr as regex):
		must.Match(expr)

	static def op_NotMatch(must as StringMust, expr as regex):
		must.Not.Match(expr)

	static def op_Equality(must as StringMust, value as string):
		must.Equal(value)

	static def op_Inequality(must as StringMust, value as string):
		must.Not.Equal(value)

	static def op_LessThan(must as StringMust, value as string):
		must.BeLessThan(value)

	static def op_GreaterThan(must as StringMust, value as string):
		must.BeGreaterThan(value)

	static def op_LessThanOrEqual(must as StringMust, value as string):
		must.BeLessThanOrEqual(value)

	static def op_GreaterThanOrEqual(must as StringMust, value as string):
		must.BeGreaterThanOrEqual(value)

