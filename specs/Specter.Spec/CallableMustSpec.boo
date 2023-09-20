#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.CallableMustContexts

import System
import Specter.Framework
import Specter.Spec
import NUnit.Framework

[TestFixture]
class CallableMustWithNonThrowingRunner:
	
	must as CallableMust
	
	[NUnit.Framework.SetUp]
	def SetUp():
		runner = def():
			pass
		asserter = Asserter(false)
		must = CallableMust(runner, asserter)
		
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def MustThrowThrows():
		must.Throw()
		
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def MustThrowTypedExceptionFails():
		must.Throw(typeof(Exception))
		
	[Test]
	def MustNotThrowDoesNotThrow():
		must.Not.Throw()

	[Test]
	def MustNotThrowDoesNotThrowTypedException():
		must.Not.Throw(typeof(Exception))
			
	[Test]
	[ExpectedException(typeof(ArgumentNullException))]
	def ThrowNullExceptionThrows():
		must.Throw(null)
		
[TestFixture]
class CallableMustWithExceptionThrowingRunner:
	must as CallableMust
	
	[NUnit.Framework.SetUp]
	def SetUp():
		runner = def():
			raise Exception()
		asserter = Asserter(false)
		must = CallableMust(runner, asserter)
		
	[Test]
	def MustThrowCatchesException():
		must.Throw()
		
	[Test]
	def MustThrowCatchesTypedException():
		must.Throw(typeof(Exception))
		
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def MustNotThrowThrowsAssertionException():
		must.Not.Throw()
	
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def MustNotThrowTypedExceptionThrowsAssertionException():
		must.Not.Throw(typeof(Exception))


[TestFixture]
class CallableMustWithArgumentExceptionThrowingRunner:

	must as CallableMust
	
	[NUnit.Framework.SetUp]
	def SetUp():
		runner = def():
			raise ArgumentException()
		must = CallableMust(runner, Asserter(false))
		
	[Test]
	[ExpectedException(typeof(ArgumentNullException))]
	def ThrowKindOfNullThrows():
		must.ThrowKindOf(null)
		
	[Test]
	def ThrowKindOfException():
		must.ThrowKindOf(typeof(Exception))
		
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def ThrowIncorrectType():
		must.Throw(typeof(string))
	
	[Test]
	[ExpectedException(typeof(Boo.Lang.Runtime.AssertionFailedException))]
	def ThrowKindOfIncorrectType():
		must.ThrowKindOf(typeof(string))
	
	[Test]
	[ExpectedException(typeof(ArgumentException))]
	def CatchingIncorrectExceptionReThrows():
		must.Throw(typeof(InvalidCastException))
		
	[Test]
	[ExpectedException(typeof(ArgumentException))]
	def CatchingIncorrectKindOfExceptionReThrows():
		must.ThrowKindOf(typeof(InvalidCastException))
		
	
[TestFixture]
class CreatingCallableMust:
	[Test]
	[ExpectedException(typeof(ArgumentNullException))]
	def CreateWithNullAsserterThrows():
		CallableMust(null, null)

