# Haskell Hangman #

----------
The Hangman word-guessing game hits a nice sweet spot when learning a new computer language. Not as trivial as "Hello World" but not overly difficult to implement.

This version of Hangman utilizes the [Haskell](https://www.haskell.org/) language, version 8.1.0. Obtain a copy of the Haskell Platform at [https://www.haskell.org/platform/](https://www.haskell.org/platform/). 

From the Hangman root directory, run the following two commands:

    cabal install random
	ghc --make hangman.hs
	
This generates the `hangman.exe` executable.  The `cabal install random` command installs the *System.Random* package.  If you are running a version of Haskell prior to version 8, skip the "cabal" step since the package is already present.

If you are new to Haskell, the book [*Learn You a Haskell for Great Good!*](http://learnyouahaskell.com/) is recommended.

If you are looking for a language to teach functional programming concepts, the recommendation is Haskell. 

Scala and many other languages borrow heavily from Haskell and its design.  In particular, Haskell pattern matching is awesome! 

The Hangman program is text based as shown by:

![console view](https://github.com/ROpsal/haskell-hangman/blob/master/images/console.png) 

