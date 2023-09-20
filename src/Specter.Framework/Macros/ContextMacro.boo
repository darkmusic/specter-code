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

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

class ContextMacro(AbstractAstMacro):

	private final SetUpMethodName = "SetUp"
	private final TearDownMethodName = "TearDown"

	private final UsageText = "Usage for 'context' is context \"description of the context\"[, <priority>])"

	public static EntryPointSet = false

	override def Expand(macro as MacroStatement):
		assert macro.Arguments.Count > 0 and macro.Arguments.Count < 3, UsageText
		assert macro.Arguments[0] isa StringLiteralExpression, "Context description must be a string literal.\n${UsageText}"
		assert macro.Arguments.Count < 2 or macro.Arguments[1] isa IntegerLiteralExpression, "Context priority must be an integer literal.\n${UsageText}"

		if not Parameters.OutputType == CompilerOutputType.Library:
			AsserterFactory.AsserterType = AsserterType.Specter

		//automatically load nunit.framework reference dependency if necessary
		if AsserterFactory.AsserterType == AsserterType.NUnit:
			if not Parameters.FindAssembly("nunit.framework"):
				asm = Parameters.LoadAssembly("nunit.framework", true)
				//NameResolutionService.OrganizeAssemblyTypes(asm)
				Parameters.AddAssembly(asm)

		contextName = SafeIdentifierName(macro.Arguments[0])
		classDef = ClassDefinition(Name: contextName)

		parentMacro = GetParentMacro(macro)
		if parentMacro is not null:
			classDef.Annotate(Annotations.Context, contextName)

		if AsserterFactory.AsserterType == AsserterType.NUnit:
			attr = Attribute(typeof(NUnit.Framework.TestFixtureAttribute).FullName)
			classDef.Attributes.Add(attr)
		attr = Attribute(typeof(ContextDescriptionAttribute).FullName)
		attr.Arguments.Add(macro.Arguments[0])
		if macro.Arguments.Count > 1:
			attr.Arguments.Add(macro.Arguments[1])
		classDef.Attributes.Add(attr)

		for add as callable in (AddFields, AddSetupMethod, AddTearDownMethod, AddSpecifyMethods):
			add(classDef, macro.Body)

		parent as Node = macro
		while not parent isa Module:
			parent = parent.ParentNode
		(parent as Module).Members.Add(classDef)

		if Steps.ContextAnnotations.GetEntryPoint(Context) is null and not ContextMacro.EntryPointSet:
			method = Method("Main", Modifiers:  TypeMemberModifiers.Static)
			method.Body = [|
					block:
						runner = Specter.Framework.Runner((System.Reflection.Assembly.GetExecutingAssembly(),))
						runner.View = Specter.Framework.ConsoleRunnerView()
						return runner.Run(true)
				|].Body
			method.Attributes.Add(Attribute(typeof(System.STAThreadAttribute).FullName))
			(parent as Module).Members.Add(method)
			ContextMacro.EntryPointSet = true

		AddInnerContextClasses(classDef, parent)

		pp = Parameters.Pipeline
		Parameters.Pipeline.AfterStep += def(sender, e as CompilerStepEventArgs):
			if e.Step isa Steps.MacroProcessing.MacroExpander:
				# Re-run BindAndApplyAttributes since we've added some to the AST.
				pp.Get(typeof(Steps.MacroProcessing.BindAndApplyAttributes)).Run()

	private def GetParentMacro(node as Node):
		if node.ParentNode is not null:
			return node.ParentNode.ParentNode as MacroStatement
		else:
			return null

	private def AddInnerContextClasses(classDef as ClassDefinition, module as Module):
		for cd in module.Members:
			if (cd isa ClassDefinition) and (cd.ContainsAnnotation(Annotations.Context)) and (cd[Annotations.Context].Equals(classDef.Name)):
				newCd = cd as ClassDefinition
				newCd.BaseTypes.Add(SimpleTypeReference(classDef.FullName))

				setup = newCd.Members[SetUpMethodName] as Method
				if setup is not null:
					setup.Body.Statements.Insert(
						0,
						ExpressionStatement(
							MethodInvocationExpression(
								MemberReferenceExpression(
									SuperLiteralExpression(),
									SetUpMethodName
								)
							)
						)
					)

				teardown = newCd.Members[TearDownMethodName] as Method
				if teardown is not null:
					teardown.Body.Statements.Insert(
						0,
						ExpressionStatement(
							MethodInvocationExpression(
								MemberReferenceExpression(
									SuperLiteralExpression(),
									TearDownMethodName
								)
							)
						)
					)

	private def AddFields(classDef as ClassDefinition, existingBlock as Block):
		finder = DeclarationStatementFinder()
		existingBlock.Accept(finder)

		for ds in finder.DeclarationStatements:
			field = Field(Name: ds.Declaration.Name, Type: ds.Declaration.Type)
			if ds.Initializer is not null:
				field.Initializer = ds.Initializer.CloneNode()
			classDef.Members.Add(field)

	private def AddSetupMethod(classDef as ClassDefinition, existingBlock as Block):
		method = AddSingleMethod(Annotations.Setup, SetUpMethodName, classDef, existingBlock)
		if method is not null:
			if AsserterFactory.AsserterType == AsserterType.NUnit:
				method.Attributes.Add(Attribute(typeof(NUnit.Framework.SetUpAttribute).FullName))
			method.Attributes.Add(Attribute(typeof(SetUpAttribute).FullName))
			AddSubjectDescriptionAttributes(method, classDef)

	private def AddTearDownMethod(classDef as ClassDefinition, existingBlock as Block):
		method = AddSingleMethod(Annotations.TearDown, TearDownMethodName, classDef, existingBlock)
		if method is not null:
			if AsserterFactory.AsserterType == AsserterType.NUnit:
				method.Attributes.Add(Attribute(typeof(NUnit.Framework.TearDownAttribute).FullName))
			method.Attributes.Add(Attribute(typeof(TearDownAttribute).FullName))

	private def AddSingleMethod(annotation as string, name as string, classDef as ClassDefinition, existingBlock as Block):
		finder = BlockFinder(annotation)
		finder.Visit(existingBlock)

		assert finder.Blocks.Length < 2, "The macro ${annotation} cannot be used more than once in a context"

		if finder.Blocks.Length == 1:
			method = Method(name, Modifiers: TypeMemberModifiers.Virtual)
			method.Body.Add(finder.Blocks[0].CloneNode())
			classDef.Members.Add(method)

		return method

	private def AddSpecifyMethods(classDef as ClassDefinition, existingBlock as Block):
		finder = BlockFinder(Annotations.Specify)
		finder.Visit(existingBlock)

		for block in finder.Blocks:
			name = cast(string, block[Annotations.Specify])
			method = Method(name)
			method.Body.Add(block.CloneNode())

			if AsserterFactory.AsserterType == AsserterType.NUnit:
				method.Attributes.Add(Attribute(typeof(NUnit.Framework.TestAttribute).FullName))
			attr = Attribute(typeof(SpecificationDescriptionAttribute).FullName)
			attr.Arguments.Add(cast(StringLiteralExpression, block[Annotations.SpecifyDescription]))
			method.Attributes.Add(attr)

			AddSubjectDescriptionAttributes(method)

			if block.ContainsAnnotation(Annotations.Ignore):
				if AsserterFactory.AsserterType == AsserterType.NUnit:
					method.Attributes.Add(Attribute(typeof(NUnit.Framework.IgnoreAttribute).FullName))
				method.Attributes.Add(Attribute(typeof(IgnoreAttribute).FullName))

			classDef.Members.Add(method)


	private def AddSubjectDescriptionAttributes(method as Method):
		AddSubjectDescriptionAttributes(method, null)

	private def AddSubjectDescriptionAttributes(method as Method, classDef as ClassDefinition):
			subjectFinder = BlockFinder(Annotations.SubjectTypeName)
			subjectFinder.Visit(method.Body)
			for subjectBlock in subjectFinder.Blocks:
				attr = Attribute(typeof(SubjectDescriptionAttribute).FullName)
				attr.Arguments.Add(cast(StringLiteralExpression, subjectBlock[Annotations.SubjectTypeName]))
				if subjectBlock.ContainsAnnotation(Annotations.SubjectDescription):
					attr.Arguments.Add(cast(StringLiteralExpression, subjectBlock[Annotations.SubjectDescription]))
				if classDef is null:
					method.Attributes.Add(attr)
				else:
					classDef.Attributes.Add(attr)

