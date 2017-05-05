#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Spec.StringMustContexts

import System
import Specter.Framework
import Specter.Spec
import NUnit.Framework

context "StringMust with \"hello world\" value, sensitive case and normal asserter":
	
	must as StringMust
	
	setup:
		must = StringMust("hello world", false, Asserter(false))
	
	specify { must.Equal(cast(string, null)) }.Must.Throw()
	
	specify { must.Equal("hello world") }.Must.Not.Throw()
	
	specify { must.Not.Equal("hello world") }.Must.Throw()
	
	specify { must.Equal("foo bar") }.Must.Throw()
	
	specify { must.Not.Equal("foo bar") }.Must.Not.Throw()
	
		
	specify "Equality op":
		{ must == "hello world" }.Must.Not.Throw()
	
	specify "Inequality op":
		{ must != "hello world" }.Must.Throw()
	
	specify "Equality op against wrong value":
		{ must == "foo bar" }.Must.Throw()
	
	specify "Inequality op against wrong value":
		{ must != "foo bar" }.Must.Not.Throw()
		
	specify "Not inequality op against wrong value":
		{ must.Not != "foo bar" }.Must.Throw()
	
	specify "Not equality op against wrong value":
		{ must.Not == "foo bar" }.Must.Not.Throw()
	
	
	specify { must.Not.BeEmpty() }.Must.Not.Throw()
	
	specify { must.BeEmpty() }.Must.Throw()
	
	
	specify { must.StartWith(null) }.Must.Throw()
	
	specify { must.StartWith("hello") }.Must.Not.Throw()
	
	specify { must.Not.StartWith("hello") }.Must.Throw()
	
	specify { must.StartWith("foo") }.Must.Throw()
	
	specify { must.Not.StartWith("foo") }.Must.Not.Throw()
	
	
	specify { must.EndWith(null) }.Must.Throw()
	
	specify { must.EndWith("world") }.Must.Not.Throw()
	
	specify { must.Not.EndWith("world") }.Must.Throw()
	
	specify { must.EndWith("foo") }.Must.Throw()
	
	specify { must.Not.EndWith("foo") }.Must.Not.Throw()
	
	
	specify { must.Contain(null) }.Must.Throw()
	
	specify { must.Contain("hello") }.Must.Not.Throw()
	
	specify { must.Not.Contain("hello") }.Must.Throw()
	
	specify { must.Contain("foo") }.Must.Throw()
	
	specify { must.Not.Contain("foo") }.Must.Not.Throw()
	
	
	specify { must.Match(null) }.Must.Throw()
	
	specify { must.Match(/[a-z\s]+/) }.Must.Not.Throw()
	
	specify { must.Not.Match(/[a-z\s]+/) }.Must.Throw()
		
	specify { must.Match(/[A-Z]+/) }.Must.Throw()
	
	specify { must.Not.Match(/[A-Z]+/) }.Must.Not.Throw()
	
	specify { must =~ /[a-z\s]+/}.Must.Not.Throw()
	
	specify { must =~ /[A-Z]+/}.Must.Throw()
	
	specify { must.Not =~ /[a-z\s]+/}.Must.Throw()
	
	specify { must.Not =~ /[A-Z]+/}.Must.Not.Throw()
	
	
context "Case-insensitive StringMust":
	
	must as StringMust
	
	setup:
		must = StringMust("hEllO WOrLD", true, Asserter(false))
		
	specify { must == "hello world" }.Must.Not.Throw()
	
	specify { must != "hello world" }.Must.Throw()

context "StringMust with null asserter":
	specify "creation will throw":
		{ StringMust("foo", false, null) }.Must.Throw(typeof(ArgumentNullException))
