#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.UInt16MustContexts

import System
import Specter.Framework
import Specter.Spec
import NUnit.Framework
			
context "UInt16Must with value 0 and normal asserter":
	must as UInt16Must
	zero as ushort
	one as ushort
	
	setup:
		zero = cast(ushort, 0)
		one = cast(ushort, 1)
		must = UInt16Must(zero, Asserter(false))
		
	specify "Not inverts spec":
		{ must.Equal(zero) }.Must.Not.Throw()
		{ must.Not.Equal(zero) }.Must.Throw()
		{ must.Not.Not.Equal(zero) }.Must.Not.Throw()
		
	specify { must.Equal(zero) }.Must.Not.Throw()
		
	specify { must.Equal(one) }.Must.Throw()
		
	specify { must.Not.Equal(zero) }.Must.Throw()
		
	specify { must.Not.Equal(one) }.Must.Not.Throw()
	

	specify { must == zero }.Must.Not.Throw()
		
	specify { must == one }.Must.Throw()
	
	specify { must != zero }.Must.Throw()
	
	specify { must != one}.Must.Not.Throw()
		

	specify { must.Be < zero }.Must.Throw()
	
	specify { must.Be > zero }.Must.Throw()
	
	specify { must.Be <= zero }.Must.Not.Throw()
	
	specify { must.Be >= zero }.Must.Not.Throw()
	
	
	specify { must.Be < one }.Must.Not.Throw()
	
	specify { must.Be > one }.Must.Throw()
	
	specify { must.Be <= one }.Must.Not.Throw()
	
	specify { must.Be >= one }.Must.Throw()

	specify must.Satisfy({ x as int | return x == 0})
	
	specify must.Not.Satisfy({ x as int | return x != 0})
	
context "UInt16Must with value 42 and normal asserter":
	must as UInt16Must
	one as ushort
	value as ushort
	
	setup:
		one = cast(ushort, 1)
		value = cast(ushort, 42)
		must = UInt16Must(value, Asserter(false))
		
	specify "Not inverts spec":
		{ must.Equal(value) }.Must.Not.Throw()
		{ must.Not.Equal(value) }.Must.Throw()
		{ must.Not.Not.Equal(value) }.Must.Not.Throw()
		
	specify { must.Equal(value) }.Must.Not.Throw()
		
	specify { must.Equal(one) }.Must.Throw()
		
	specify { must.Not.Equal(value) }.Must.Throw()
		
	specify { must.Not.Equal(one) }.Must.Not.Throw()
	

	specify { must == value }.Must.Not.Throw()
		
	specify { must == one }.Must.Throw()
	
	specify { must != value }.Must.Throw()
	
	specify { must != one}.Must.Not.Throw()
		

	specify { must.Be < value }.Must.Throw()
	
	specify { must.Be > value }.Must.Throw()
	
	specify { must.Be <= value }.Must.Not.Throw()
	
	specify { must.Be >= value }.Must.Not.Throw()
	
	
	specify { must.Be < ushort.MaxValue }.Must.Not.Throw()
	
	specify { must.Be > ushort.MaxValue }.Must.Throw()
	
	specify { must.Be <= ushort.MaxValue }.Must.Not.Throw()
	
	specify { must.Be >= ushort.MaxValue }.Must.Throw()

	specify must.Satisfy({ x as int | return x == value})
	
	specify must.Not.Satisfy({ x as int | return x != value})

