#region license
# Copyright (c) 2006, Andrew Davey
# Copyright (c) 2008, Cedric Vivier <cedricv@neonux.com>
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

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

class SpecifyMacro(AbstractAstMacro):

	private final UsageText = "Usage for 'specify' is specify { code }.Must* _or_ specify \"behavior description\": block"

	override def Expand(macro as MacroStatement):
		assert 1 == macro.Arguments.Count, UsageText

		if not Parameters.OutputType == CompilerOutputType.Library:
			AsserterFactory.AsserterType = AsserterType.Specter

		name = SafeIdentifierName(macro.Arguments[0])
		block = macro.Block.CloneNode()
		block.Annotate(Annotations.Specify, name)
		if not (macro.Arguments[0] isa StringLiteralExpression):
			block.Annotate(Annotations.SpecifyDescription, StringLiteralExpression(macro.Arguments[0].ToCodeString()))
			block.Insert(0, macro.Arguments[0])
		else:
			block.Annotate(Annotations.SpecifyDescription, macro.Arguments[0])

		if block.Statements.Count == 0:
			block.Annotate(Annotations.Ignore)

		createAsserter as MethodInvocationExpression = null
		if AsserterFactory.AsserterType == AsserterType.NUnit:
			createAsserter = [| AsserterFactory.CreateNUnitAsserter() |]
		else:
			createAsserter = [| AsserterFactory.CreateSpecterAsserter() |]

		r = MustReplacer(createAsserter)
		r.Visit(block)	

		return block


class MustReplacer(DepthFirstTransformer):
	
	private _createAsserter as MethodInvocationExpression
	
	def constructor(createAsserter as MethodInvocationExpression):
		_createAsserter = createAsserter

	override def OnMemberReferenceExpression(node as MemberReferenceExpression):		
		if node.Name == "Must":
			mie = MethodInvocationExpression(
				Target: MemberReferenceExpression(Name: node.Name, Target: node.Target))
			
			# Add message argument
			p as Node = node
			
			while not (p.ParentNode isa Block):
				p = p.ParentNode
			
			message = p.ToCodeString()
			message = ReplaceOperatorsWithEnglish(message)
				
			message = /[.]([A-Z])/.Replace(message, { m as Match | return " " + m.Groups[1].Value.ToLower() })
			message = @/\(|\)/.Replace(message, " ")
			message = /([a-z])([A-Z])/.Replace(message, { m as Match | return m.Groups[1].Value.ToUpper() + " " + m.Groups[2].Value.ToLower() }) 
			message = message.Trim()
			
			messageExpr = StringLiteralExpression(message)
			
			create = _createAsserter.CloneNode()
			create.Arguments.Add(messageExpr)
			mie.Arguments.Add(create)
			
			ReplaceCurrentNode(mie)
		else:
			super.OnMemberReferenceExpression(node)

