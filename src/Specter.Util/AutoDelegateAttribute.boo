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
import Boo.Lang.Compiler.TypeSystem

class AutoDelegateAttribute(AbstractAstAttribute):

	private _interfaceReference as ReferenceExpression
	private _field as Field
	
	def constructor(interfaceReference as ReferenceExpression):
		_interfaceReference = interfaceReference

	override def Apply(targetNode as Node):
		# Get the class definition we're applied to
		assert targetNode isa Field, "AutoDelegateAttribute must be applied to a field of a class"
		_field = targetNode
		assert _field.ParentNode isa ClassDefinition, "AutoDelegateAttribute must be applied to a field of a class"
		classDef = _field.ParentNode as ClassDefinition
				
		context = self.Context
		Parameters.Pipeline.AfterStep += def(sender, args as CompilerStepEventArgs):
			if not args.Step isa Steps.BindTypeMembers: return 
						
			e = TypeSystemServices.GetEntity(classDef)
			NameResolutionService.EnterNamespace(e) 
			
			interfaceType as IType = NameResolutionService.Resolve(_interfaceReference.Name) 
						
			for member as IEntity in interfaceType.GetMembers():
				invokingMember as TypeMember = null
				if member isa IMethod:
					invokingMember = CreateMethod(member, context)
				elif member isa IProperty:
					invokingMember = CreateProperty(member, context)
				elif member isa IEvent:
					context.Warnings.Add(CompilerWarning(targetNode.LexicalInfo, "Cannot delegate implementation of event '${member.FullName}'."))
				else:
					context.Errors.Add(CompilerError("Unknown member type ${member.FullName}"))
				
				classDef.Members.Add(invokingMember) unless invokingMember is null

			
	def CreateMethod(member as IMethod, context as CompilerContext):
		# Get the method we'll be calling
		mixinMethod = NameResolutionService.ResolveMethod(
			NameResolutionService.Resolve(_interfaceReference.Name),
			member.Name
		)
		
		# Create the method that will call it
		method = context.CodeBuilder.CreateMethod(member.Name, member.ReturnType, TypeMemberModifiers.Public)
		for i, parameter as IParameter in enumerate(mixinMethod.GetParameters()):
			method.Parameters.Add(context.CodeBuilder.CreateParameterDeclaration(i, parameter.Name, parameter.Type))
		
		invoke = context.CodeBuilder.CreateMethodInvocation(
			context.CodeBuilder.CreateReference(_field),
			mixinMethod
		)
		# Add the arguments
		for parameter in mixinMethod.GetParameters():
			invoke.Arguments.Add(context.CodeBuilder.CreateReference(parameter))
		
		method.Body.Add(invoke)
		
		return method
		
	def CreateProperty(interfaceProperty as IProperty, context as CompilerContext):
		b = context.CodeBuilder
		
		property = b.CreateProperty(interfaceProperty.Name, interfaceProperty.Type)
						
		if interfaceProperty.GetGetMethod() is not null:
			property.Getter = b.CreateMethod("get_${interfaceProperty.Name}", interfaceProperty.Type, TypeMemberModifiers.Public)
			property.Getter.Body.Add(
				ReturnStatement(
					MemberReferenceExpression(
						Name: interfaceProperty.Name,
						Target: MemberReferenceExpression(
							Target: SelfLiteralExpression(),
							Name: _field.Name
						)
					)
				)
			)
		
		if interfaceProperty.GetSetMethod() is not null:
			property.Setter = b.CreateMethod("set_${interfaceProperty.Name}", b.TypeSystemServices.VoidType, TypeMemberModifiers.Public)
			property.Setter.Body.Add(
				BinaryExpression(
					BinaryOperatorType.Assign,
					MemberReferenceExpression(
						Target:MemberReferenceExpression(
							Target: SelfLiteralExpression(),
							Name: _field.Name
						),
						Name: interfaceProperty.Name
					),
					ReferenceExpression("value")
				)
			)
		
		return property
