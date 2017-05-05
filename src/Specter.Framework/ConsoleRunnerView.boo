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


class ConsoleRunnerView(AbstractRunnerView):

	_runner as IRunner

	_currentSpecResult = "?"
	
	_contextsToRun = 0
	_specsToRun = 0
	_contextsRan = 0
	_specsRan = 0
	
	_cdescHash as int
	_contextsSucceedUnique = List of int()
	_contextsFailedUnique = List of int()
	_specsSucceed = 0
	_specsFailed = 0
	
	_startedAt as DateTime
	_duration as TimeSpan

	def OnBeginRun(runner as IRunner):
		if runner is null:
			raise ArgumentNullException("runner")
		_runner = runner

		if not _runner.DisableColors:
			try:
				Console.ForegroundColor = ConsoleColor.Red
				Console.ResetColor()
			except: #shell does not support color (e.g emacs shell)
				_runner.DisableColors = true

		print "Specter Framework - Console Runner - ${_runner.Version}"
		print ""
				
		runner.GetToRunCount(_contextsToRun, _specsToRun)
		print "Specifications to run  : ${_specsToRun} (in ${_contextsToRun} contexts)"
		print ""
		_startedAt = DateTime.Now

	def OnEndRun(runner as IRunner, succeed as bool):
		Console.Write(Environment.NewLine)
		Console.Write(Environment.NewLine)

		if runner.Exceptions.Count > 0:
			Console.ForegroundColor = ConsoleColor.DarkRed unless _runner.DisableColors
			print "FAILURES"
			print ""
			Console.ResetColor() unless _runner.DisableColors

		n = 1
		cc as ContextDescriptionAttribute = null #current context
		lc as ContextDescriptionAttribute = null #last context
		lmsg as string = null #last msg
		for e in runner.Exceptions:
			Console.ForegroundColor = ConsoleColor.DarkRed unless _runner.DisableColors
			cc = e.Specification.Context.Description
			if cc != lc:
				print "Context: ${cc.Text}"
				print ""
			print "    [${n}] ${e.Specification.Description.Text}"
			Console.ResetColor() unless _runner.DisableColors
			ResetPrettyExceptionMessage()
			msg = BuildPrettyExceptionMessage(e)
			print msg
			print ""
			#TODO: aggregation
			lmsg = msg
			lc = cc
			n++
		
		print ""		
		Console.ForegroundColor = ConsoleColor.DarkGreen unless _runner.DisableColors
		print "Specifications passed  : ${_specsSucceed} (in ${_contextsSucceedUnique.Count} contexts)"
		Console.ForegroundColor = ConsoleColor.DarkRed unless _runner.DisableColors
		print "Specifications failed  : ${_specsFailed} (in ${_contextsFailedUnique.Count} contexts)"
		print ""
		Console.ResetColor() unless _runner.DisableColors
		_duration = DateTime.Now - _startedAt
		conclusion = "${_specsRan} specifications (in ${_contextsRan} contexts) tested in ${_duration}."
		print conclusion
		Console.Title = conclusion #change console title for taskbar/dock flashing

	def OnBeginContext(context as Context):
		_cdescHash = context.GetHashCode()
		if not _runner.EnableCompact:
			Console.ResetColor() unless _runner.DisableColors
			Console.Write(Environment.NewLine) if _specsRan != 0
			Console.Write(context.Description.Text)
			Console.Write(Environment.NewLine)
	
	def OnEndContext(context as Context, succeed as bool):
		_contextsRan++

	def OnBeginSpecification(spec as Specification):
		_currentSpecResult = "."

	def OnEndSpecificationSetUp(spec as Specification, succeed as bool):
		_currentSpecResult = "S" if not succeed

	def OnEndSpecificationTearDown(spec as Specification, succeed as bool):
		_currentSpecResult = "T" if not succeed
	
	def OnEndSpecification(spec as Specification, succeed as bool):
		if not _runner.DisableColors:
			Console.ForegroundColor = ConsoleColor.DarkGreen if succeed
			Console.ForegroundColor = ConsoleColor.DarkRed if not succeed
		_currentSpecResult = "F" if not succeed and _currentSpecResult == "."
		Console.Write(_currentSpecResult)
		_specsRan++
		_specsSucceed++ if succeed
		_specsFailed++ if not succeed
		_contextsSucceedUnique.Add(_cdescHash) if succeed and not _contextsSucceedUnique.Contains(_cdescHash)
		_contextsFailedUnique.Add(_cdescHash) if not succeed and not _contextsFailedUnique.Contains(_cdescHash)


	_indent = "        "
	_msg as System.Text.StringBuilder
	private def BuildPrettyExceptionMessage(e as Exception) as string:
		ResetPrettyExceptionMessage() if _msg is null
		if e isa SpecificationException:
			BuildPrettyExceptionMessage(e.InnerException)
		elif e isa AssertionFailedException or e isa SubjectTypeNotFoundException or e isa SubjectConstructorNotFoundException or e.GetType().Name == "AssertionException":
			_msg.Append(_indent)
			_msg.Append(e.Message)
			if e isa AssertionFailedException and (e as AssertionFailedException).HasValues:
				_msg.Append(Environment.NewLine)
				_msg.Append(_indent)
				_msg.Append("    Actual : ")
				_msg.Append((e as AssertionFailedException).Actual)
				_msg.Append(Environment.NewLine)
				_msg.Append(_indent)
				_msg.Append("    Expected : ")
				_msg.Append((e as AssertionFailedException).Expected)
		elif e isa SpecificationSetUpException:
			_msg.Append(_indent)
			_msg.Append("SetUp failed because of the following :")
			_msg.Append(Environment.NewLine)
			BuildPrettyExceptionMessage(e.InnerException)
		elif e isa SpecificationTearDownException:
			_msg.Append(_indent)
			_msg.Append("TearDown failed because of the following :")
			_msg.Append(Environment.NewLine)
			BuildPrettyExceptionMessage(e.InnerException)
		else:
			_msg.Append(_indent)
			_msg.Append(e.ToString())

		return _msg.ToString()

	private def ResetPrettyExceptionMessage():
		if _msg is null:
			_msg = System.Text.StringBuilder()
		else:
			_msg.Length = 0

