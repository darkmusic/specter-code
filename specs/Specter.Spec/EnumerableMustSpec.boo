#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.EnumerableMustContexts

import System
import Specter.Framework
import Specter.Spec
import NUnit.Framework

context "EnumerableMust with empty list":
	
	must as EnumerableMust
	
	setup:
		must = EnumerableMust([], Asserter(false))
		
	specify { must.BeEmpty() }.Must.Not.Throw()
	
	specify { must.Not.BeEmpty() }.Must.Throw()
	
	
	specify { must.Equal([]) }.Must.Not.Throw()
	
	specify { must.Not.Equal([]) }.Must.Throw()
	
	specify { must.Equal([1]) }.Must.Throw()
	
	specify { must.Not.Equal([1]) }.Must.Not.Throw()
	
	
	specify { must.AllSatisfy({ o | return true}) }.Must.Not.Throw()
	
	specify { must.AllSatisfy({ o | return false}) }.Must.Not.Throw()
	
	specify { must.SomeSatisfy({ o | return true}) }.Must.Throw()
	
	specify { must.SomeSatisfy({ o | return false}) }.Must.Throw()
	
	
context "EnumerableMust with list 1, 2, 3":
	must as EnumerableMust
	
	setup:
		must = EnumerableMust([1, 2, 3], Asserter(false))
		
	specify { must.BeEmpty() }.Must.Throw()
	
	specify { must.Not.BeEmpty() }.Must.Not.Throw()
	
	specify { must.Contain(1) }.Must.Not.Throw()
	
	specify { must.Contain(4) }.Must.Throw()
	
	specify { must.Not.Contain(1) }.Must.Throw()
	
	specify { must.Not.Contain(4) }.Must.Not.Throw()
	
	specify { must.Equal([]) }.Must.Throw()
	
	specify { must.Not.Equal([]) }.Must.Not.Throw()
	
	specify { must.Equal([1, 2, 3]) }.Must.Not.Throw()
	
	specify { must.Not.Equal([1, 2, 3]) }.Must.Throw()
	
	specify { must.Equal([1, 2, 3, 4]) }.Must.Throw()
	
	specify { must.Not.Equal([1, 2, 3, 4]) }.Must.Not.Throw()
	
	
	specify { must.AllSatisfy({ o | return true}) }.Must.Not.Throw()
	
	specify { must.Not.AllSatisfy({ o | return true}) }.Must.Throw()
	
	specify { must.SomeSatisfy({ o | return true}) }.Must.Not.Throw()
	
	specify { must.Not.SomeSatisfy({ o | return true}) }.Must.Throw()
	
	specify { must.AllSatisfy({o | return cast(int, o) > 0 }) }.Must.Not.Throw()
	
	specify { must.AllSatisfy({o | return cast(int, o) > 10 }) }.Must.Throw()
	
	specify { must.SomeSatisfy({o | return cast(int, o) > 2 }) }.Must.Not.Throw()
	
	specify { must.SomeSatisfy({o | return cast(int, o) > 10 }) }.Must.Throw()
