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

<sup>Note: you can mostly skip this section if you already know what a Turing machine is; you’ll only need the last Turing machine for the second part.</sup>

The Turing machine is a computational model – you say that a system is Turing complete if it can emulate an arbitrary Turing machine.
A Turing machine itself is a simple data processing machine:
it operates step by step on a tape, on which it can move left and right, and its behavior is governed by what it reads from the tape and its internal state.

More precisely, a Turing machine is a collection of states, where each state maps an input character to an output character, a movement instruction (<strong>l</strong>eft, <strong>r</strong>ight, <strong>n</strong>o movement), and a “next” state.
To run a Turing machine, you write the input word on the tape, and then in each step you
1. read a character from the Turing machine’s current position (it starts at the first input character)
2. read the output character for this character from the Turing machine’s current state, and write it
3. read the movement for this character from the Turing machine’s current state, and execute it – move by one step in the appropriate direction (or don’t move)
4. read the next state for this character from the Turing machine’s current state, and set the current state to that
5. repeat.

When the Turing machine reaches a state where it doesn’t move, doesn’t change state, and writes the same character it read, then it halts.
Sometimes, the states are classified as “accepting” and “rejecting”, in which case the Turing machine “accepts” or “rejects” the input word based on the final state;
otherwise, the Turing machine performed some computation, and the result of that computation is left on the tape.

This model is relatively simple, but you can perform any calculation with it – multiplication, testing if a number is prime, anything.
I/O devices and speed left aside, your computer is no more powerful than a Turing machine, and a Turing machine could fully emulate it.

Emulating a modern PC in a Turing machine is pretty complicated, though. We’ll start simple, with a Turing machine that tests if the input has even length.

    Input: A sequence of ‘1’s of various length
    States:
    
    State | Read | Write | Move | Next state
    ========================================
    S1    | 1    | 1     | R    | S2
            ␣    | ␣     | N    | S1
    ----------------------------------------
    S2    | 1    | 1     | R    | S1
            ␣    | ␣     | N    | S2
    
    Initial state: S1
    Accepting states: S1

The Turing machine scans the input left-to-right, alternating between `S1` and `S2`.
When it reaches the end of the input – ‘␣’ means the “blank” character that’s on the empty tape – it stops.
If the input length was even, it alternated an even amount of times between S1 and S2, ending up in S1 and accepting the input (because S1 is an accepting state).
If the input length was odd, it ended up in S2 and rejected the input (because S2 is not an accepting state).

This Turing machine tested if the input length was a multiple of two; next up, we’ll test if it’s a *power* of two.
That Turing machine is a bit more complicated, and so we’ll represent it as a graph instead of a table:

![A Turing machine testing if the length of the input is a power of two](https://raw.githubusercontent.com/lucaswerkmeister/ceylon-typesystem-chomsky-3/renderedSVGs/powerOfTwo.png)

<sup>(That is a rendered version of [this file](/powerOfTwo.svg), because SVGs aren’t supported in GitHub READMEs.)</sup>

Circles denote states; the state with the small unlabeled arrow pointing into it is the initial state.
An arrow from `Q1` to `Q2` labeled `x→y|R` means: when you’re in state `Q1` and read an `x`, write a `y`, move <strong>r</strong>ight and go to state `Q2`.
A double circle marks an accepting state, the other states are rejecting.

The basic idea is to go over the input repeatedly; each time, you replace every second `x` with a `y` (which is ignored in subsequent runs).
When that always worked out, and in the end you end up with a single `x` remaining, then the input length was a power of two
(in each run, you divided it by two, and you never got an error).
If in one run there isn’t an even amount of `x`s so that you could leave and convert an equal amount of them, then the input length was not a power of two, and you reject the word (by transitioning into the “trash” state `Q0`).

Now, we will implement that Turing machine in the Ceylon type system.

<sup>Note: if I’ve done a bad job at explaining what a Turing machine is, I’m sorry; the [Wikipedia article](https://en.wikipedia.org/wiki/Turing_machine) probably does a better job.</sup>

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
