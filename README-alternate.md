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

<sup>Note: you can skip this section if you already know what a Turing machine is.</sup>

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
An arrow from `q2` to `q3` labeled `x→y|R` means: when you’re in state `q2` and read an `x`, write a `y`, move <strong>r</strong>ight and go to state `q3`.
A double circle marks an accepting state, the other states are rejecting.

The basic idea is to go over the input repeatedly; each time, you replace every second `x` with a `y` (which is ignored in subsequent runs).
When that always worked out, and in the end you end up with a single `x` remaining, then the input length was a power of two
(in each run, you divided it by two, and you never got an error).
If in one run there isn’t an even amount of `x`s so that you could leave and convert an equal amount of them, then the input length was not a power of two, and you reject the word (by transitioning into the “trash” state `q0`).

Now, we will implement that Turing machine in the Ceylon type system.

<sup>Note: if I’ve done a bad job at explaining what a Turing machine is, I’m sorry; the [Wikipedia article](https://en.wikipedia.org/wiki/Turing_machine) probably does a better job.</sup>

Emulating a Turing machine in the Ceylon type system
----------------------------------------------------

We will implement a Turing machine in the Ceylon type system by composing a function with type arguments whose return type simulates a single step of a Turing machine.
Then, by chaining many invocations of this function together – each with the result of the previous invocation as its argument – we simulate a run of the Turing machine.

The fundamental idea here is that a function can return more than one type through union types.
Given disjoint interfaces `A1` and `A2`, the return type of
```ceylon
I&A1&X |
I&A2&Y
fun<I>(I i)
        given I of A1|A2
        => nothing;
```
is assignable to
* `X` if `I` is `A1` (`I&A2` will be `Nothing`, removing the `Y` from the union)
* `Y` if `I` is `A2` (`I&A1` will be `Nothing`, removing the `X` from the union).

That’s a very basic `if` decision, and we’ll construct the Turing machine from that.

The code I showed above has a problem, though:
If you plug the return type from above into the function again, you still have the `I&A1` in addition to the `X` in it,
and if you do this again and again, you intersect more and more types onto the return type.
This is fatal if, for example, the `I&A1` branch was taken, but `X` is `A2` – the intersection of that is `Nothing`, so you’ve lost information.

You somehow need to get rid of the parts of the return type that you don’t want:
separate the decision (`I&A1`) from the result (`X`).
We do that with some more generics:

```ceylon
interface B<out T> {}
```

This is a “box” around a type.
If we now write the signature
```ceylon
I&A1&B<X> |
I&A2&B<Y>
fun<I>(B<I> i)
        given I of A1|A2
        => nothing;
```
the returned type is assignable to `B<X>` instead of `X`;
when we put that into `fun` again, we just take the inner `I` (=`X`), stripping away not only `B` but also the `I&A1` part that we don’t want.

(We now have enough to implement a DFA in the type system, as I’ve done in [source/ceylon/typesystem/demo/notDivisibleByThree/automaton.ceylon](../b47ad63a304d76986de2ef70f7e0d5426732fe25/source/ceylon/typesystem/demo/notDivisibleByThree/automaton.ceylon).)

Now, we need to capture a lot of data to implement the Turing machine: not just its current state, but also its data tape and the position on the tape.

The state is easy:
```ceylon
shared interface Q of Q0|Q1|Q2/*...*/ {}

shared interface Q0 satisfies Q {}
/*...*/
```

We will emulate the tape through a pair of stacks;
if you stick them together, you get the entire tape, and the juncture point (TODO is that correct english?) marks the current position:
the stacks
```
A   X
B   Y
C   Z
```
represent the tape
```
CBA>XYZ
```
where the `>` represents the current position on the tape.

To represent a stack in the type system, we use a linked list of types, similar to `Tuple`:
```ceylon
/* stack elements */
shared interface S of SX|SY/*...*/ {}
shared interface SX of x satisfies S {} shared object x satisfies SX {}
/*...*/

shared interface Stack
        of StackHead<S, Stack>|StackEnd
        { shared actual formal Stack rest; shared actual formal S first; }
shared interface StackHead<out Element, out Rest>
        satisfies Stack
        given Element satisfies S
        given Rest satisfies Stack
        { shared actual formal Rest rest; shared actual formal Element first; }
shared interface StackEnd
        satisfies Stack
        { shared actual formal Nothing rest; shared actual formal Nothing first; }
```

Now, the stack `SX SY SY` can be represented as the type
```ceylon
StackHead<SX, StackHead<SY, StackHead<SY, StackEnd>>>
```

Our type box now needs to contain three types instead of one (state, left stack, right stack), so we’ll expand it:
```ceylon
"Box around three types"
shared interface B<out A, out B, out C> { shared formal A first; shared formal B second; shared formal C third; }
```

The type system Turing machine could now look like this:
```ceylon
t
<out State, out LeftStack, out LeftRest, out RightStack, out RightRest, Left, Right>
(B<State, LeftStack, RightStack> state)
given State satisfies Q
given Left satisfies S
given Right satisfies S
given LeftRest satisfies Stack
given RightRest satisfies Stack
given LeftStack of StackEnd|StackHead<Left, LeftRest>
             satisfies Stack
given RightStack of StackEnd|StackHead<Right, RightRest>
             satisfies Stack
```

We need `Left` and `Right` to read the first symbol on the left/right stack;
if we formed the intersection `LeftStack&StackHead<SX, LeftRest>` and `LeftStack` was in fact a `StackHead<SY, LeftRest>`, the result would be a `LeftStack<Nothing, LeftRest>` rather than the `Nothing` that we need to make the thing work.

However, this can’t work: if `LeftStack` is a `StackEnd`, then what’s `Left` and `LeftRest`?
They’re invalid, and while we don’t care because we won’t use them in that case, the Ceylon typechecker can’t accept this because we might use these type parameters in reified generics in the body.
Therefore, we need a way to specify them, by adding more parameters:
```ceylon
t
<out State, out LeftStack, out LeftRest, out RightStack, out RightRest, Left, Right>
(B<State, LeftStack, RightStack> state, Left left, LeftRest leftRest, Right right, RightRest rightRest)
//                                      ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
given State satisfies Q
given Left satisfies S
given Right satisfies S
given LeftRest satisfies Stack
given RightRest satisfies Stack
given LeftStack of StackEnd|StackHead<Left, LeftRest>
             satisfies Stack
given RightStack of StackEnd|StackHead<Right, RightRest>
             satisfies Stack
```

And now it’s just missing the return type to complete the Turing machine:
For every possible state of the turing machine and every possible case of `Right` (all case types of `S`), as well as the case `RightStack=StackEnd`, add one “branch” to the return type, which is the intersection of
- `State`
- the state,
- either
  - `Right` and the case type of `S`, or
  - `RightStack` and `StackEnd`, and
- the box `B` around
  - the new state,
  - the new left stack, and
  - the new right stack.

The new stack is formed like this:

write?\Move?|left|no|right
----:|--------------------------------------------|-------------------------------------------|--------------------------------------------
yes  |  `LeftRest`, `StackHead<New, RightStack>`  |  `LeftStack`, `StackHead<New, RightRest>` |  `StackHead<New, LeftStack>`, `RightRest`
no   |  `LeftRest`, `StackHead<Left, RightStack>` |  `LeftStack`, `RightStack`                |  `StackHead<Right, LeftStack>`, `RightRest`

(It gets a bit more tricky when `RightStack` is `StackEnd`, because you can’t move onto the “blank” cell (that’s not really there)
unless you’re writing something to it.
Depending on your Turing machine, this might not be a problem because you might never want to move onto blank cells;
otherwise, you’ll probably need to introduce a “blank” pseudo-character that you can write onto the tape.)

Then you form the union of all these branch types, and use that union type as return type of `t`.

For example, here is the transition for a very simple Turing machine that reads the input left-to-right,
alternating between `Q1` and `Q2`, thus tracking if the input has even or odd length:

```ceylon
State&Q1 & Right&S & B<Q2, StackHead<Right, LeftStack>, RightRest> |
State&Q2 & Right&S & B<Q1, StackHead<Right, LeftStack>, RightRest> |

State&Q1 & RightStack&StackEnd & B<Q1, LeftStack, RightStack> |
State&Q2 & RightStack&StackEnd & B<Q2, LeftStack, RightStack>

        t
        <out State, out LeftStack, out LeftRest, out RightStack, out RightRest, Left, Right>
        (B<State, LeftStack, RightStack> state)
        given State satisfies Q
        given Left satisfies S
        given Right satisfies S
        given LeftRest satisfies Stack
        given RightRest satisfies Stack
        given LeftStack of StackEnd|StackHead<Left, LeftRest>
                     satisfies Stack
        given RightStack of StackEnd|StackHead<Right, RightRest>
                     satisfies Stack
        { return nothing; }
```

(Note: Normally, I would put all `Q1` branches together, then all `Q2` branches.
I grouped them differently here because in this case, `Q1` and `Q2` are almost identical.)

Now that we have that function, we just need to set up some “plumbing” – the feedback loop, so to speak.
First, we’ll need three functions to construct the initial state:

```ceylon
"Helper function to **b**uild an initial stack. See [[t]] for usage."
StackHead<First, Rest>
        b
        <out First, out Rest>
        (First first, Rest rest)
        given First satisfies S
        given Rest of StackEnd|StackHead<S, Stack>
                   satisfies Stack
{ return nothing; }

StackEnd
        e
        ()
{ return nothing; }

B<Q1, StackEnd, Input>
        initial
        <out Input>
        (Input input)
        given Input satisfies Stack
{ return nothing; }
```
We build up a stack by chaining several `b` calls (terminating with an `e()`), and then turn it into a complete state with the `initial` function:
```ceylon
value s00 = initial(b(x, b(x, b(x, e()))));
```
And then we repeatedly plug that into `t`, recording each result in a new value:
```ceylon
value s01 = t(s00, s00.second.first, s00.second.rest, s00.third.first, s00.third.rest);
value s02 = t(s01, s01.second.first, s01.second.rest, s01.third.first, s01.third.rest);
// ...
```
Each new value now represents one more iteration of the Turing machine.
Value s<em>n</em> contains the result of the Turing machine after *n* iterations.

If the Turing machine tests a certain condition (“is this number a power of two?“), then it will probably have one or more *accepting states*, and then you can summarize them like this:
```ceylon
"Accepting state(s)"
shared alias Accept => B<Q1, Stack, Stack>;
```
In this case, `Q1` is the accepting state. You can then use it like this at the end of the “iteration”:
```ceylon
Accept end = sX;
```
If this is well-typed, then your Turing machine accepted the input word after *X* iterations.

On the other hand, if your Turing machine calculates some result that you want to get, you can just let the IDE insert the inferred value for `sX` to get the result after *X* iterations.

And that’s it! We now have emulated a Turing machine in the Ceylon type system. Great!

A full example of a Turing machine that tests if the length of the input word is a power of two can be found [here](https://github.com/lucaswerkmeister/ceylon-typesystem-turing-complete/tree/386f9913d22f51d533e52e0a343307703aac83fd/source/ceylon/typesystem/demo/powerOfTwo).


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
