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
import System.Text.RegularExpressions

import Boo.Lang.Compiler.Ast 


static def SafeIdentifierName(input as string):
	input = ReplaceOperatorsWithEnglish(input)
	input = @/ ([a-z])/.Replace(input, 
		{ m as Match |
			return m.Groups[1].Value.Trim().ToUpper()
		}
	)
	input = @/[^_a-zA-Z0-9]/.Replace(input, string.Empty)
	if /^[^_a-zA-Z]/.IsMatch(input):
		input = "_" + input
	
	return input

static def SafeIdentifierName(input as Expression):
	if input isa StringLiteralExpression:
		return SafeIdentifierName((input as StringLiteralExpression).Value)
	return SafeIdentifierName(input.ToString())

static def ReplaceOperatorsWithEnglish(message as string):
	operators = [ 
				("==" , "equal"),
				("!=" , "not equal"),
				(">=" , "greater than or equal"),
				("<=" , "less than or equal"),
				("<"  , "less than"),
				(">"  , "greater than")
				]
	for op as (string) in operators:
		message = message.Replace(op[0], op[1])
		
	return message

