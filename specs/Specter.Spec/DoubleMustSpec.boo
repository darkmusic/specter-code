#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.DoubleMustContexts

import System
import Specter.Framework
import Specter.Spec

context "DoubleMust with 0.0 value":
	
	must as DoubleMust
	
	setup:
		must = DoubleMust(0.0, Asserter(false))
		
	specify { must.BeLessThan(100.0) }.Must.Not.Throw()
	
	specify { must.BeLessThanOrEqual(100.0) }.Must.Not.Throw()
	
	specify { must.BeGreaterThan(-1.0) }.Must.Not.Throw()
	
	specify { must.BeGreaterThanOrEqual(-1.0) }.Must.Not.Throw()
	
	
	specify { must.BeWithin(double.Epsilon).Of(0.0) }.Must.Not.Throw()

context "DoubleMust with infinity value":
	
	specify double.NegativeInfinity.Must.BeInfinity()
	
	specify double.NegativeInfinity.Must.BeNegativeInfinity()
	
	specify double.PositiveInfinity.Must.BePositiveInfinity()
	
	specify double.NaN.Must.BeNan()
	
	specify double.NegativeInfinity.Must.Not.BePositiveInfinity()
	
	specify double.PositiveInfinity.Must.Not.BeNegativeInfinity()


context "DoubleMust with value 42":
	
	must as DoubleMust
	
	setup:
		must = DoubleMust(42.0, Asserter(false))
		
	specify { must.BeWithin(0.1).Of(42.0) }.Must.Not.Throw()
