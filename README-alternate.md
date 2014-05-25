Ceylon Type System is Turing Complete
=====================================

<sup>Note: you can find an alternate README in [README.md](/README.md).</sup>

The type system of the [Ceylon programming language](http://ceylon-lang.org) is Turing complete,
which means that it is possible to rewrite any question that a computer can answer (“Is this number a power of two? What do you get if you multiply six by nine?”) as a Ceylon typing problem.
If it’s a yes/no question, you get the answer by checking if the program is well-typed or not (does it compile without errors?);
otherwise you get the answer from an inferred return type (use, for example, “insert inferred type <...>” from your IDE of choice).

“How the hell is that possible?”, you ask? I’ll show you, but first I need to tell you what Turing machines are,
because what we’ll be doing in the second part of this “article” <!-- TODO article? blog post? what? --> is to emulate a Turing machine in the Ceylon type system.

Turing machines
---------------

TODO

Emulating a Turing machine in the Ceylon type system
----------------------------------------------------

TODO

Addendum: Just how Turing complete is it?
-----------------------------------------

As you have seen in the previous section, the type system is Turing complete if you provide an “external” feedback loop –
meaning that the loop is not implemented in the type system directly, but instead provided by repeating a line of code, slightly varied, over and over.

You might of course question if that really makes the Ceylon type system itself Turing complete.
I believe that it qualifies as Turing complete, for the following reasons:

1. The feedback loop is very primitive, and
2. It would be fundamentally bad if you didn’t need the feedback loop.

### The feedback loop is primitive

That’s a simple argument. The feedback loop is merely:
* Keep track of one or two (depending on how you count – in any case, O(1)) symbols
* Replace placeholders in a constant line with the “previous” and “current” symbol
* Generate said symbols so that they will never repeat. I used arabic numbers for that, but you could also enumerate the Unicode letters, or repeat a single character again and again, or do something entirely different.

If you investigate where the Turing completeness “comes from”, it’s most certainly not from the feedback loop – it comes from the type system.

### You _should_ need the feedback loop

Why?
Wouldn’t it be cool if the type system could solve arbitrary problems without ever growing code?

The answer must be a definite **no**.
Imagine what that would mean:
As there are Turing machines that run forever (trivial: write ‘1’, move right, repeat), it would mean that there would be programs for which _compilation_ would run forever.
Let me repeat that: Compilation of any program might potentially take minutes, hours, or never ever complete – and you could never be sure.

You might be thinking now that the compiler could surely recognize when its compilation will never end, but that’s not really possible:
To decide whether a given Turing machine will halt on a given input is called the [Halting Problem](https://en.wikipedia.org/wiki/Halting_Problem), and it’s undecidable.
In general, there’s no faster way than to run the Turing machine and hope that it will, in fact, terminate – if it doesn’t, you can never be sure if it’s in a loop or if it’s simply taking very long.

Compilation of a program should always be decidable.
You should always be guaranteed that your probram will, eventually, compile either successfully or with errors, but compilation will terminate.
If you could, in a program of constant size, emulate a Turing machine that runs arbitrarily many steps over some given input,
you could not have that guarantee.
