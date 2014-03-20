Ceylon Type System is Chomsky-3-complete
========================================

The type system / typechecker of the Ceylon programming language is Chomsky-3-complete, meaning that it can recognize regular languages.

What does that mean?

It means, for example, that it is possible to define a function `t`, an alias `Accept`, an object `initial`, and some other internal types, such that
```ceylon
Accept q = t(t(t(t(t(initial, _1), _6), _7), _3), _5);
```
compiles, but
```ceylon
Accept q = t(t(t(t(t(initial, _1), _6), _7), _3), _4);
```
doesn’t, because 16735 isn’t divisible by three, but 16734 is.
In other words, this statement compiles iff the arguments to the recursive `t` call chain form a number that isn’t divisible by three.

How does this work?

To explain this, we’ll first take an excursion and look at the theory of *regular languages*.

Theoretical stuff
-----------------

First, some simple terms:

* An **alphabet** is a set of characters, for example { a, b } for very simple examples or { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } for natural numbers.
* A **word** over an alphabet is a sequence of characters from that alphabet.
  For example, 12345 would be a word over the alphabet defined above.
  (Warning: This is slightly different from the normal use of the term; if your alphabet contains the space character, then “The rain in spain stays mainly in the plain” is *one* word.)
* A **language** is simply a set of words over an alphabet.
  You can define it directly – for example, { 1, 12, 123 } might me the language of my favorite numbers – but most useful languages are defined over some rule that all words in the language must fulfill, like “the language of all numbers not divisible by three” or “the language of all valid Ceylon programs”.
* And, last but not least, a **regular language** is a language that can be *recognized* by a Deterministic Finite Automaton (DFA).

What’s a deterministic finite automaton now? It’s a theoretical concept that’s usually represented like this:

[!image] TODO

Every circle represents a *state* that the automaton can be in; at any time, it’s in exactly one state.
We start off in the state that’s marked with a little unlabeled arrow.
The automaton then reads the characters of the input word one after the other, and for each character it transitions into a different (or the same) state according to the arrow exiting the current state that’s labelled with the read character.
For example, in the automaton above, the input TODO leads to the state transitions T->O->D->O.
If the last state is an *accepting* state – which is usually marked by a double-line border – then the automaton *accepts* the word, which means that this word is in the language recognized by the automaton.

One more example. The automaton to recognize numbers that aren’t divisible by three looks like this:

[!image] TODO

Now, we want to encode that automaton into the Ceylon type system.

… transformed into code
-------------------------

We already saw how the result should be used:
```ceylon
Accept q = t(t(t(t(t(initial, _1), _6), _7), _3), _5);
```
should compile because 16735 is accepted by the automaton that we saw earlier, which is in turn because 16735 isn’t divisible by three.
`t` is the state transition function. It accepts a state as first argument, an input character as second argument, and then returns the following state.
`initial` is the initial state, and `Accept` is an alias to the union of all accepting states.
Thus, the statement compiles iff the state that the function returns on the last call is assignable to the union of accepting states – that is, if it’s an accepting state.

First of all, let’s get all the boring stuff out of the way. Here’s types and objects for all states and inputs:
```ceylon
/* alphabet */
shared abstract class X0() of _0 {} shared object _0 extends X0() {}
shared abstract class X1() of _1 {} shared object _1 extends X1() {}
shared abstract class X2() of _2 {} shared object _2 extends X2() {}
shared abstract class X3() of _3 {} shared object _3 extends X3() {}
shared abstract class X4() of _4 {} shared object _4 extends X4() {}
shared abstract class X5() of _5 {} shared object _5 extends X5() {}
shared abstract class X6() of _6 {} shared object _6 extends X6() {}
shared abstract class X7() of _7 {} shared object _7 extends X7() {}
shared abstract class X8() of _8 {} shared object _8 extends X8() {}
shared abstract class X9() of _9 {} shared object _9 extends X9() {}

/* states */
shared interface Q of Q0|Q1|Q2 {}
"Remainder 0"
shared interface Q0 satisfies Q {}
"Remainder 1"
shared interface Q1 satisfies Q {}
"Remainder 2"
shared interface Q2 satisfies Q {}

"Accepting state(s)"
shared alias Accept => B<Q1|Q2>;

"Initial state"
shared object initial satisfies B<Q0> {}

"Input that adds no remainder"
shared alias R0 => X0|X3|X6|X9;
"Input that adds 1 to remainder"
shared alias R1 => X1|X4|X7;
"Input that adds 2 to remainder"
shared alias R2 => X2|X5|X8;
```

That’s all not very interesting – all the magic happens in the `t` function.

Now, how does this function work? `t` can only have one return type!
Well, the basic idea is to stuff loads of information into that type by making it a union type.
We have one “branch” for each input state and input character, and then put the output state into that branch as well.
We select the correct branch by making each branch the intersection of its expected state and input, the actual state and input, and then add the resulting state to that as an intersection as well.

That gives us this:
```ceylon
shared

S&Q0 & C&R0 & Q0 |
S&Q0 & C&R1 & Q1 |
S&Q0 & C&R2 & Q2 |

S&Q1 & C&R0 & Q1 |
S&Q1 & C&R1 & Q2 |
S&Q1 & C&R2 & Q0 |

S&Q2 & C&R0 & Q2 |
S&Q2 & C&R1 & Q0 |
S&Q2 & C&R2 & Q1

        t<S,C>(S state, C x)
        given S of Q
        given C of X0|X1|X2|X3|X4|X5|X6|X7|X8|X9
{ return nothing; }
```

As you can see, all the magic happens in the return type – the function doesn’t actually *do* anything (which makes sense, since we’re only interested in compile-time behaviour).
Each of the three return “blocks” is for one state, and each line in there for a group of input characters (if I added a line for each individual character, it would be even bigger!).
For example, the line `S&Q1 & C&R1 & Q2` evaluates to something assignable to `Q2` if `S` is `Q1` and `C` is of `R1`, and to `Nothing` otherwise.
Of all these branches, exactly one is not `Nothing`, so the total result is the union of many `Nothing`s – which the typechecker throws away – and one interesting “branch”, which then contains the resulting state.

So does this work? Unfortunately, it doesn’t (the problem may even be obvious to you – it wasn’t to me, though).
Fortunately, there’s a pretty simple fix that still keeps the same principle.

What’s the problem? Well, let’s look again at that line we had earlier: `S&Q1 & C&R1 & Q2`.
I said that this was assignable to `Q2`.
That wasn’t wrong – but the actual result isn’t really intended.
Since all the state types are disjoint (forced disjoint by the declaration of `interface Q of Q0|Q1|Q2`), and the type contains the intersection `Q1&Q2`, the resulting type is `Nothing`.
Of course, `Nothing` is assignable to everything – especially, it will propagate as `S` through the `t` chain (intersected with even more states, which changes nothing) and in the end, of course, *always* be assignable to `Accept`, no matter what we’ve entered.

To solve this, we need to somehow strip the selection part of the branch – the `S&Q1 & C&R1` – from the return type, since we only care about the `Q2`.
For this, we introduce a new type that’s simply a “box” around another type:
```ceylon
"Box around a type"
shared interface B<out T> {}
```
and use that in the function:
```ceylon
shared

S&Q0 & C&R0 & B<Q0> |
S&Q0 & C&R1 & B<Q1> |
S&Q0 & C&R2 & B<Q2> |

S&Q1 & C&R0 & B<Q1> |
S&Q1 & C&R1 & B<Q2> |
S&Q1 & C&R2 & B<Q0> |

S&Q2 & C&R0 & B<Q2> |
S&Q2 & C&R1 & B<Q0> |
S&Q2 & C&R2 & B<Q1>

        t<S,C>(B<S> state, C x)
        given S of Q
        given C of X0|X1|X2|X3|X4|X5|X6|X7|X8|X9
{ return nothing; }
```
Note that the first argument is now of type `B<S>` instead of `S`.
Even if it’s a `Q0&R0&B<S>`, we don’t care, since we only cherry-pick the `S` part.

And that’s it! Now it works, and we’ve encoded the automaton into the type system.
(You can see the entire file in [source/ceylon/typesystem/demo/notDivisibleByThree/automaton.ceylon].)

So what?
--------

So what’s this good for, you ask?
Well, I’m not sure.
In principle, it’s certainly cool that you have such a powerful typesystem (see below for even more coolness).
The technique used here might also be useful to framework authors to do multiple things with a single function.

But wait, there’s more!
-----------------------

TODO. Cliffhanger :)
