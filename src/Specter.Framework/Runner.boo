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
import System.Reflection
import System.Collections.Generic


class Runner(IRunner):

	[getter(Assemblies)]
	_assemblies = List of Assembly()

	[property(View)]
	_view as IRunnerView

	[getter(Exceptions)]
	_exceptions = List of SpecificationException()

	Version:
		get:
			return Assembly.GetExecutingAssembly().GetName().Version

	[property(DisableColors)]
	_disableColors = false

	[getter(EnableCompact)]
	_enableCompact = false

	[getter(QuietMode)]
	_quietMode = false

	_contexts = List[of Context]()
	_contextsSetUp = Dictionary[of Type, MethodInfo]()
	_contextsTearDown = Dictionary[of Type, MethodInfo]()

	[getter(XmlOut)]
	_xmlOut = false

	[getter(XmlFile)]
	_xmlFile as string = null


	def constructor():
		pass


	def constructor(assemblies as (Assembly)):
		if assemblies is null:
			raise ArgumentNullException("assemblies")
		for asm in assemblies:
			_assemblies.Add(asm)


	def GetToRunCount(ref contextsToRun as int, ref specsToRun as int):
		contextsToRun = _contexts.Count
		specsToRun = 0
		for context in _contexts:
			specsToRun += context.Specifications.Count


	def Run(processCmdLineArgs as bool) as int:
		ProcessEnvVars()
		if processCmdLineArgs:
			ProcessCmdLineArgs()

		_view = null if _quietMode

		GetContextsSorted()
		_view.OnBeginRun(self) unless _view is null
		
		for context in _contexts:
			contextSucceed = true
			_view.OnBeginContext(context) unless _view is null

			c = Activator.CreateInstance(context.Type)

			for spec in context.Specifications:
				specSucceed = true
				specSetUpSucceed = true
				specTearDownSucceed = true

				_view.OnBeginSpecification(spec) unless _view is null

				if _contextsSetUp.ContainsKey(context.Type):
					_view.OnBeginSpecificationSetUp(spec) unless _view is null
					try:
						_contextsSetUp[context.Type].Invoke(c, null)
					except e:
						contextSucceed = false
						specSucceed = false
						specSetUpSucceed = false
						_exceptions.Add(SpecificationSetUpException(spec, e.InnerException))
						_view.OnException(e.InnerException) unless _view is null
					_view.OnEndSpecificationSetUp(spec, specSetUpSucceed) unless _view is null

				if specSetUpSucceed:
					try:
						spec.MethodInfo.Invoke(c, null)
					except e:
						contextSucceed = false
						specSucceed = false
						_exceptions.Add(SpecificationException(spec, e.InnerException))
						_view.OnException(e.InnerException) unless _view is null

				if _contextsTearDown.ContainsKey(context.Type):
					_view.OnBeginSpecificationTearDown(spec) unless _view is null
					try:
						_contextsTearDown[context.Type].Invoke(c, null)
					except e:
						contextSucceed = false
						specSucceed = false
						specTearDownSucceed = false
						_exceptions.Add(SpecificationTearDownException(spec, e.InnerException))
						_view.OnException(e.InnerException) unless _view is null
					_view.OnEndSpecificationTearDown(spec, specTearDownSucceed) unless _view is null

				_view.OnEndSpecification(spec, specSucceed) unless _view is null

			_view.OnEndContext(context, contextSucceed) unless _view is null

		_view.OnEndRun(self,  0 == _exceptions.Count) unless _view is null

		return _exceptions.Count


	private def ProcessCmdLineArgs():
		args = Environment.GetCommandLineArgs()
		for arg in args:
			continue if arg is args[0]
			if arg == "-help" or arg == "--help" or arg == "-h" or arg == "-?":
				DisplayLogo()
				print "Usage is : ${args[0]} [options] file1 ..."
				print "Options :"
				print "-help       show this help message"
				print "-quiet      disable output, only return exit code (short: -q)"
				print "-compact    do not show context in progress"
				print "-nocolors   disable colors (you can also set SPECTER_NOCOLORS environment var)"
				print "-xml[:file] display results as XML (optional file output instead of stdout)"
				print ""
				print "For more information please visit http://specter.sourceforge.net/"
				print ""
				Environment.Exit(0)
			elif arg == "-quiet" or arg == "-q":
				_quietMode = true
			elif arg == "-compact":
				_enableCompact = true
			elif arg == "-nocolors":
				_disableColors = true

			elif arg == "-xml" or arg.StartsWith("-xml:"):
				_xmlOut = true
				_xmlFile = StripQuotes(arg.Substring(5)) if arg != "-xml"
				_view = XmlReportView()

			elif arg.StartsWith("-"):
				DisplayLogo()
				print "Invalid option :  ${arg}"
				print "Type '${args[0]} -help' if you're lost."
				print ""
				Environment.Exit(0)
			else:
				try:
					_assemblies.Add(Assembly.LoadFile(arg))
				except e:
					print "WARNING: failed to add assembly '${arg}'"
		if 0 == _assemblies.Count:
			DisplayLogo()
			print "There is no spec assembly to test !"
			print "Type '${args[0]} -help' if you're lost."
			print ""
			Environment.Exit(0)

	private def ProcessEnvVars():
		_disableColors = true if Environment.GetEnvironmentVariable("SPECTER_NOCOLORS") is not null

	private def GetContextsSorted():
		contextPriorityComparer = ContextPriorityComparer()
		specPriorityComparer = SpecificationPriorityComparer()
		for asm in _assemblies:
			for type in asm.GetTypes():
				if 1 == type.GetCustomAttributes(typeof(ContextDescriptionAttribute), false).Length:
					c = Context(Type: type)
					c.Description = type.GetCustomAttributes(typeof(ContextDescriptionAttribute), false)[0]
					//c.Subjects = type.GetCustomAttributes(typeof(SubjectDescriptionAttribute), false)
					specs = List of Specification()
					for method in type.GetMethods():
						if 1 == method.GetCustomAttributes(typeof(SpecificationDescriptionAttribute), false).Length:
							sdesc = method.GetCustomAttributes(typeof(SpecificationDescriptionAttribute), false)[0]
							// ssubjects = method.GetCustomAttributes(typeof(SubjectDescriptionAttribute), false)
							//specs.Add(Specification(Context: c, Description: sdesc, Subjects: ssubjects, MethodInfo: method))
							specs.Add(Specification(Context: c, Description: sdesc, MethodInfo: method))
						elif 1 == method.GetCustomAttributes(typeof(SetUpAttribute), false).Length:
							_contextsSetUp.Add(type, method)
						elif 1 == method.GetCustomAttributes(typeof(TearDownAttribute), false).Length:
							_contextsTearDown.Add(type, method)
					specs.Sort(specPriorityComparer)
					c.Specifications = specs
					_contexts.Add(c)
		_contexts.Reverse()
		_contexts.Sort(contextPriorityComparer)

	private def DisplayLogo():
		print "Specter Framework - Console Runner - ${Version}"
		print ""

	private static def StripQuotes(s as string) as string:
		if s.Length > 1 and s.StartsWith("\"") and s.EndsWith("\""):
			return s.Substring(1,s.Length-2)
		return s

