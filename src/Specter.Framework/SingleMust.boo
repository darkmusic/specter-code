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
def Must(x as single, asserter as IAsserter):
	return SingleMust(x, asserter)
	
[NumericMust(single)]
class SingleMust:
			
	def BeWithin(tolerance as single) as SingleTolerance:
		return SingleTolerance(tolerance, _value, _asserter)
	
	def BeNan():
		_asserter.Assert(single.IsNaN(_value))
		
	def BeInfinity():
		_asserter.Assert(single.IsInfinity(_value))
		
	def BePositiveInfinity():
		_asserter.Assert(single.IsPositiveInfinity(_value))
		
	def BeNegativeInfinity():
		_asserter.Assert(single.IsNegativeInfinity(_value))
				
class SingleTolerance:
	
	private _tolerance as single
	private _value as single
	private _asserter as IAsserter
	
	def constructor(tolerance as single, value as single, asserter as IAsserter):
		_tolerance = tolerance
		_value = value
		_asserter = asserter
	
	def Of(expected as single):
		_asserter.Assert(Math.Abs(_value - expected) < single.Epsilon)
	
	
