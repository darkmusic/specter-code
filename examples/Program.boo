namespace Examples

import System
import Specter.Framework


context "Bar":
	specify 42.Must.Be < 420

	specify "hello":
		# no body means this will be ignored by NUnit
		pass

# Demoing outer context having inner contexts...
context "Outer":

	state1 as object

	setup:
		state1 = object()

	specify "foobar":
		pass

	context "Inner1":
		state2 as object

		# This setup will call parent class setup first		
		setup:
			state2 = object()

		specify "Testing":
			print state1
			print state2

	context "Inner2":
		state2 as object

		setup:
			state2 = object()
			

context "Demo":

	specify "String":
		"hello".Must.Equal("hello")
		"hello".Must.IgnoringCase.Equal("HELLO")
		"hello".Must.Not.Equal("world")

	specify "hello".Must.Match(/[a-z]+/)

	specify "Double":
		0.42.Must.Equal(0.42)
		0.42.Must.BeWithin(0.001).Of(0.42)
		0.42.Must.BeLessThan(0.43)
		0.42.Must.BeGreaterThan(0.41)

		0.42.Must != 0
		0.42.Must.Be < 0.43

		i = double.PositiveInfinity
		i.Must.BeInfinity()
		i.Must.BePositiveInfinity()

	specify 42.Must.Not.Equal(40)

	specify 42.0.Must != 20

	specify { raise Exception() }.Must.Throw()

	specify { raise ArgumentException() }.Must.Throw(typeof(ArgumentException))

	specify "Enumerable":
		a = [1,2,3,4]
		b = [1,2,3,4]
		a.Must.Equal(b)

	specify "Enumerable2":
		a = [1,2,3,4]
		b = [1,2,3]
		a.Must.Not.Equal(b)
		b.Must.Not.Equal(a)

	specify "Enumerable3":
		a as System.Collections.IEnumerable = null
		b as System.Collections.IEnumerable = null
		a.Must.Not.Equal(b)

	specify "Enumerable4":
		a = [1,2,3]
		b as System.Collections.IEnumerable = null
		a.Must.Not.Equal(b)
		b.Must.Not.Equal(a)

	specify "boolean":
		x = true
		x.Must.BeTrue()
		x.Must.Not.BeFalse()

	specify "date":
		d = date(2006, 9, 25)
		d.Must.BeLessThan(date.Now)

print "everything is cool."
gets()
