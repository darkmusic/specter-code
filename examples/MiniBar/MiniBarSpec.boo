#
# As an exercise you can write the implementation of this spec
#
# 1) compile the spec referencing a empty library with just Bender namespace
# 2) run the spec, you'll get SubjectTypeNotFound errors
# 3) add the MiniBar class into Bender namespace, compile library
# 4) run the spec, you'll get MissingMethod errors
# 5) implement the required method/property in MiniBar class, compile library
# 6) ???
# 7) PROFIT !!!
#

import Specter.Framework

import Bender


context "At Bender's bar":

	_bar as duck #our subject is defined in the setup block below

	setup:
		subject _bar = Bender.MiniBar()

	#one-liner shorthand
	specify { _bar.DrinkOneBeer() }.Must.Not.Throw()

	specify "If I drink 5 beers then I owe 5 bucks":
		for i in range(5):
			_bar.DrinkOneBeer()
		_bar.Balance.Must.Equal(-5)

	specify "If I drink more than ten beers then I get drunk":
		for i in range(10):
			_bar.DrinkOneBeer()
		{ _bar.DrinkOneBeer() }.Must.Throw()

