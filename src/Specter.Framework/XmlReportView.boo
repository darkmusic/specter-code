#region license
# Copyright (c) 2008, Cedric Vivier <cedricv@neonux.com>
# Copyright (c) 2008, Jeffery Olson <jeffery.olson@gmail.com>
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
import System.Xml
import System.IO
import System.Text


class XmlReportView(AbstractRunnerView):

	_runner as IRunner
	_fgColorBak as ConsoleColor

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

	_needDispose = false
	_stream as StreamWriter = null
	_xmlWriter as XmlTextWriter = null
	_streamReader as StreamReader = null


	def constructor(): #default is stdout
		pass


	def constructor(stream as TextWriter):
		_xmlWriter = XmlTextWriter(stream)


	def OnBeginRun(runner as IRunner):
		if runner is null:
			raise ArgumentNullException("runner")
		_runner = runner
		if _xmlWriter is null:
			if _runner.XmlFile is not null:
				_stream = StreamWriter(_runner.XmlFile, false, Encoding.UTF8)
				_stream.AutoFlush = true
				_xmlWriter = XmlTextWriter(_stream)
			else: #default is stdout
				_xmlWriter = XmlTextWriter(Console.Out)

		#_xmlWriter = XmlTextWriter(Console.Out)
		_xmlWriter.Formatting = Formatting.Indented
		_xmlWriter.Indentation = 4
		_xmlWriter.Namespaces = false

		_xmlWriter.WriteStartDocument()

		runner.GetToRunCount(_contextsToRun, _specsToRun)

		_xmlWriter.WriteStartElement("SpecterRun")
		_xmlWriter.WriteAttributeString("version", "${_runner.Version}")

		culture = System.Threading.Thread.CurrentThread.CurrentCulture
		System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture
		_startedAt = DateTime.Now
		_xmlWriter.WriteAttributeString("startedAt", _startedAt.ToUniversalTime().ToString())
		System.Threading.Thread.CurrentThread.CurrentCulture = culture


	def OnEndRun(runner as IRunner, succeed as bool):
		_xmlWriter.WriteStartElement("Summary")
		culture = System.Threading.Thread.CurrentThread.CurrentCulture
		System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture
		_xmlWriter.WriteAttributeString("duration", _duration.ToString())
		System.Threading.Thread.CurrentThread.CurrentCulture = culture

		_xmlWriter.WriteStartElement("Succeeded")
		_xmlWriter.WriteAttributeString("specs", _specsSucceed.ToString())
		_xmlWriter.WriteAttributeString("contexts", _contextsSucceedUnique.Count.ToString())
		_xmlWriter.WriteEndElement()

		_xmlWriter.WriteStartElement("Failed")
		_xmlWriter.WriteAttributeString("specs" ,_specsFailed.ToString())
		_xmlWriter.WriteAttributeString("contexts", _contextsFailedUnique.Count.ToString())
		_xmlWriter.WriteEndElement()

		_xmlWriter.WriteStartElement("Ran")
		_xmlWriter.WriteAttributeString("specs", _specsRan.ToString())
		_xmlWriter.WriteAttributeString("contexts", _contextsRan.ToString())
		_xmlWriter.WriteEndElement()

		_xmlWriter.WriteEndElement()

		_xmlWriter.WriteEndElement()
		_xmlWriter.WriteEndDocument()

		if _stream is null:
			Console.Out.Flush()
		else:
			_stream.Close()
		_xmlWriter.Close()


	def OnBeginContext(context as Context):
		_cdescHash = context.GetHashCode()
		_xmlWriter.WriteStartElement("Context")
		_xmlWriter.WriteAttributeString("description", context.Description.Text)
		if context.Subjects is not null and len(context.Subjects) > 0:
			_xmlWriter.WriteStartElement("Subjects")
			for subject in context.Subjects:
				_xmlWriter.WriteStartElement("Subject")	
				_xmlWriter.WriteAttributeString("typeName", subject.TypeName)
				if subject.Description is not null and len(subject.Description) > 0:
					_xmlWriter.WriteAttributeString("description", subject.Description)
				_xmlWriter.WriteEndElement()
			_xmlWriter.WriteEndElement()


	def OnEndContext(context as Context, succeed as bool):
		_contextsRan++
		_xmlWriter.WriteEndElement()

	def OnBeginSpecification(spec as Specification):
		_currentSpecResult = "."
		_xmlWriter.WriteStartElement("Specification")
		_xmlWriter.WriteAttributeString("description",spec.Description.Text)

	def OnEndSpecificationSetUp(spec as Specification, succeed as bool):
		_currentSpecResult = "S" if not succeed


	def OnEndSpecificationTearDown(spec as Specification, succeed as bool):
		_currentSpecResult = "T" if not succeed


	def OnEndSpecification(spec as Specification, succeed as bool):
		_currentSpecResult = "F" if not succeed and _currentSpecResult == "."

		if (_currentSpecResult.Equals("S")):
			_xmlWriter.WriteAttributeString("succeeded","false")
			_xmlWriter.WriteAttributeString("failPoint","Setup")

		elif (_currentSpecResult.Equals("T")):
			_xmlWriter.WriteAttributeString("succeeded","false")
			_xmlWriter.WriteAttributeString("failPoint","TearDown")

		elif (_currentSpecResult.Equals("F")):
			_xmlWriter.WriteAttributeString("succeeded","false")
			_xmlWriter.WriteAttributeString("failPoint","Specify")

		else:
			_xmlWriter.WriteAttributeString("succeeded","true")

		if not succeed:
			_xmlWriter.WriteStartElement("Exception")
			for e in _runner.Exceptions:
				if e.Specification.Description == spec.Description:
					_xmlWriter.WriteString(e.ToString())
			_xmlWriter.WriteEndElement()
			#TODO: more human-friendly elements (<actual... <expected...)

		if spec.Subjects is not null and len(spec.Subjects) > 0:
			_xmlWriter.WriteStartElement("Subjects")
			for subject in spec.Subjects:
				_xmlWriter.WriteStartElement("Subject")	
				_xmlWriter.WriteAttributeString("typeName", subject.TypeName)
				if subject.Description is not null and len(subject.Description) > 0:
					_xmlWriter.WriteAttributeString("description", subject.Description)
				_xmlWriter.WriteEndElement()
			_xmlWriter.WriteEndElement()

		_xmlWriter.WriteEndElement()

		_specsRan++
		_specsSucceed++ if succeed
		_specsFailed++ if not succeed
		_contextsSucceedUnique.Add(_cdescHash) if succeed and not _contextsSucceedUnique.Contains(_cdescHash)
		_contextsFailedUnique.Add(_cdescHash) if not succeed and not _contextsFailedUnique.Contains(_cdescHash)

