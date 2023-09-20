#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.ObjectMustContexts

import System
import Specter.Framework
import Specter.Spec

class Stub(EventArgs, IComparable):
	value = 42
	
	def constructor():
		pass
		
	def constructor(val as int):
		value = val
		
	override def Equals(obj):
		return (obj as Stub).value == value
	
context "ObjectMust with null asserter":
	specify { ObjectMust(null, null) }.Must.Throw(typeof(ArgumentNullException))
			
context "ObjectMust with null reference":
	
	must as ObjectMust
	
	setup:
		must = ObjectMust(null, Asserter(false))
		
	specify { must.BeNull() }.Must.Not.Throw()
	
	specify { must.Not.BeNull() }.Must.Throw()
	
	specify "Cannot ref equal instance":
		obj = object()
		{ must.ReferentiallyEqual(obj) }.Must.Throw()
		{ must.Not.ReferentiallyEqual(obj) }.Must.Not.Throw()
		
context "ObjectMust with object instance":
	
	must as ObjectMust
	obj as object
	
	setup:
		obj = object()
		must = ObjectMust(obj, Asserter(false))
		
	specify { must.ReferentiallyEqual(obj) }.Must.Not.Throw()
	
	specify { must.Not.ReferentiallyEqual(obj) }.Must.Throw()
	
	specify { must.BeNull() }.Must.Throw()
	
	specify { must.Not.BeNull() }.Must.Not.Throw()
		
context "ObjectMust with Stub object instance":
	
	obj as Stub
	must as ObjectMust
	
	setup:
		obj = Stub()
		must = ObjectMust(obj, Asserter(false))
	
	specify { must.BeInstanceOf(typeof(Stub)) }.Must.Not.Throw()
	
	specify { must.Not.BeInstanceOf(typeof(Stub)) }.Must.Throw()
	
	specify { must.BeInstanceOf(typeof(EventArgs)) }.Must.Throw()
	
	specify { must.Not.BeInstanceOf(typeof(EventArgs)) }.Must.Not.Throw()
	
	
	specify { must.BeKindOf(typeof(Stub)) }.Must.Not.Throw()
	
	specify { must.Not.BeKindOf(typeof(Stub)) }.Must.Throw()
	
	specify { must.BeKindOf(typeof(EventArgs)) }.Must.Not.Throw()
	
	specify { must.Not.BeKindOf(typeof(EventArgs)) }.Must.Throw()
	
	specify { must.BeKindOf(null) }.Must.Throw()
	
	specify { must.BeInstanceOf(null) }.Must.Throw()
	
	specify { must.BeKindOf(typeof(string)) }.Must.Throw()
	
	
	specify { must.Equal(Stub()) }.Must.Not.Throw()

	specify { must.Equal(Stub(10)) }.Must.Throw()
	
	//specify { Stub(10).Must == Stub(10) }.Must.Not.Throw()
	
	//specify { Stub(10).Must == Stub(9) }.Must.Throw(typeof(NUnit.Framework.AssertionException))
