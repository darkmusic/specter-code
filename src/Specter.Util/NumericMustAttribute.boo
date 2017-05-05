#region license
# Copyright (c) 2006, Andrew Davey
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Andrew Davey nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Util

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

[AttributeUsage(AttributeTargets.Class)]
class NumericMustAttribute(AbstractAstAttribute):

	private _type as SimpleTypeReference

	def constructor(type as ReferenceExpression):
		_type = SimpleTypeReference(type.Name)

	override def Apply(targetNode as Node):
		targetClass = targetNode as ClassDefinition

		code as ClassDefinition = [|
			class NumericMust(IComparableMust, IEquatableMust, ISatisfiableMust):
				private _value as @T
				private _asserter as IAsserter

				[AutoDelegate(IComparableMust)]
				private _comparableMust as IComparableMust
				[AutoDelegate(IEquatableMust)]
				private _equatableMust as IEquatableMust
				[AutoDelegate(ISatisfiableMust)]
				private _satisfiableMust as ISatisfiableMust

				def constructor(value as @T, asserter as IAsserter):
					_value = value
					_asserter = asserter as IAsserter

					_satisfiableMust = SatisfiableMust(value, asserter)
					_equatableMust = EquatableMust(value, asserter)
					_comparableMust = ComparableMust(value, asserter)

				Not:
					get:
						return @C(_value, _asserter.Inverted)

				def Equal(expected as @T):
					_asserter.Assert(_value.Equals(expected), _value, expected)

				def BeLessThan(expected as @T):
					_asserter.Assert(_value < expected, _value, "less than ${expected}")

				def BeLessThanOrEqual(expected as @T):
					_asserter.Assert(_value <= expected, _value, "less than or equal ${expected}")

				def BeGreaterThan(expected as @T):
					_asserter.Assert(_value > expected, _value, "greater than ${expected}")

				def BeGreaterThanOrEqual(expected as @T):
					_asserter.Assert(_value >= expected, _value, "greater than or equal ${expected}")

				Be:
					get:
						return self

				static def op_Equality(must as @C, value as @T):
					must.Equal(value)

				static def op_Inequality(must as @C, value as @T):
					must.Not.Equal(value)

				static def op_LessThan(must as @C, value as @T):
					must.BeLessThan(value)

				static def op_GreaterThan(must as @C, value as @T):
					must.BeGreaterThan(value)

				static def op_LessThanOrEqual(must as @C, value as @T):
					must.BeLessThanOrEqual(value)

				static def op_GreaterThanOrEqual(must as @C, value as @T):
					must.BeGreaterThanOrEqual(value)
		|]
		valueReplacer = TypeReplacer("@T", _type)
		code.Accept(valueReplacer)

		classReplacer = TypeReplacer("@C", SimpleTypeReference(targetClass.Name))
		code.Accept(classReplacer)

		for member in code.Members:
			targetClass.Members.Add(member)

		for base in code.BaseTypes:
			targetClass.BaseTypes.Add(base)

class TypeReplacer(DepthFirstTransformer):
	private _name as string
	private _type as SimpleTypeReference

	def constructor(name as string, type as SimpleTypeReference):
		_name = name
		_type = type

	override def OnSimpleTypeReference(node as SimpleTypeReference):
		if node.Name == _name:
			ReplaceCurrentNode(_type)

	override def OnMethodInvocationExpression(node as MethodInvocationExpression):
		# Check for constructor calls
		if (node.Target as ReferenceExpression).Name == _name:
			node.Target = ReferenceExpression(_type.Name)
		super.OnMethodInvocationExpression(node)

