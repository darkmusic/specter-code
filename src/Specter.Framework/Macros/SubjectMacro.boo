#region license
# Copyright (c) 2008, Cedric Vivier <cedricv@neonux.com>
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
# Neither the name of Cedric Vivier nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Specter.Framework

import System
import System.Collections.Generic

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

class SubjectMacro(AbstractAstMacro):

	private final UsageText = "Usage for 'subject' is subject [<description>,] <expression> ( ex: subject x = MyNamespace.MySubject() )"

	protected static _qualifiedRefs as List of string
	protected static _qualifiedRefsLock as object = object()

	[getter(Description)]
	protected _description as string

	[getter(TypeName)]
	protected _typeName as string


	override def Expand(macro as MacroStatement):
		assert macro.Arguments.Count == 1 or macro.Arguments.Count == 2, UsageText
		if macro.Arguments.Count == 2:
			assert macro.Arguments[0] isa StringLiteralExpression, "Subject description must be a string literal expression.\n${UsageText}"
			_description = (macro.Arguments[0] as StringLiteralExpression).Value
		expression = macro.Arguments[-1] as BinaryExpression
		assert expression is not null and expression.Operator == BinaryOperatorType.Assign, "Subject must have a assignment expression instantiating the fully-qualified subject.\n${UsageText}"

		subjectHolder = expression.Left as ReferenceExpression
		subjectTypeName = GetSubjectTypeName(expression)

		#FIXME: move this to run-time? qrefs in module?
		_typeName = GetValidQualifiedTypeName(subjectTypeName)

		mie = expression.Right as MethodInvocationExpression
		temp as Expression = NullLiteralExpression()
		if 0 == mie.Arguments.Count:
			assignment  = [|
				block:
					$subjectHolder = System.Activator.CreateInstance(System.Type.GetType($_typeName)) as duck
			|].Block
		else:
			temp = ReferenceExpression("__specter_ctorArgsArray")
			assignment = Block()
			assignment.Add([| $temp = array(object, $(mie.Arguments.Count)) |])
			i = 0
			for arg in mie.Arguments:
				assignment.Add([| $temp[$i] = $arg |])
				i++
			#FIXME: call to overload workaround (,null)	 =>  BOO-933
			assignment.Add([| $subjectHolder = System.Activator.CreateInstance(System.Type.GetType($_typeName), $temp, null) as duck |])

		block = [|
			block:
				try:
					$assignment #TODO: FIXME: boo>0.8  =>  .withLexicalInfoFrom(expression)
				except e as System.ArgumentNullException: #type not found => gettype returns null
					raise SubjectTypeNotFoundException($_typeName, e)
				except e as System.MissingMethodException:
					raise SubjectConstructorNotFoundException($_typeName, $temp, e)
		|].Block

		if _description is not null:
			block.Annotate(Annotations.SubjectDescription, StringLiteralExpression(_description))
		block.Annotate(Annotations.SubjectTypeName, StringLiteralExpression(_typeName))

		return block


	protected def GetSubjectTypeName(expression as BinaryExpression) as string:
		mie = expression.Right as MethodInvocationExpression
		miet = mie.Target as ReferenceExpression
		if miet is null:
			return GetGenericSubjectTypeName(expression)
		if -1 == miet.ToString().IndexOf("."):
			Context.Warnings.Add(CompilerWarningFactory.CustomWarning(expression.LexicalInfo, "You should use fully-qualified type as subject. (ex: YourNamespace.${miet.ToString()})"))

		entity = NameResolutionService.Resolve(miet.Name)
		return entity.FullName if entity is not null

		subjectTypeName = miet.ToString() #TODO:
		Context.Warnings.Add(CompilerWarningFactory.CustomWarning(expression.LexicalInfo, "Subject '${subjectTypeName}' does not exist. Maybe it isn't implemented yet or you forgot an assembly reference ?"))

		return subjectTypeName


	protected def GetGenericSubjectTypeName(expression as BinaryExpression) as string:
		raise NotImplementedException("Generic types are not supported yet with the subject macro. Please write your code without subject macro here for now.")


	protected def CacheQualifiedReferences():
		lock _qualifiedRefsLock:
			if not _qualifiedRefs: #cache referenced assemblies
				_qualifiedRefs = List of string()
				for asm in Parameters.References:
					_qualifiedRefs.Add(asm.FullName) if asm.Name != 'mscorlib' #no need to qualify mscorlib for GetType(string)


	protected def GetValidQualifiedTypeName(subjectTypeName):
		CacheQualifiedReferences()
		for qualifiedRef in _qualifiedRefs:
			qualifiedTypeName = subjectTypeName + ", " + qualifiedRef
			break if Type.GetType(qualifiedTypeName) is not null
		return qualifiedTypeName

