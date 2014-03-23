/* alphabet */
"The normal word character."
shared abstract class X() of x satisfies SX {} shared object x extends X() {}
"Auxiliary character – every second [[x]] is replaced by [[y]]."
abstract class Y() of y satisfies SY {} object y extends Y() {}

/* states */
shared interface Q of Q0|Q1|Q2|Q3|Q4|Q5|Q6 {}

"“Trash” state. Loops forever.
 
 Transitions:
 * read anything: write it back, stay put, stay in this state"
shared interface Q0 satisfies Q {}

"Start state. We return to this state each time we have cycled back over the word.
 
 Transitions:
 * read [[x]]: write [[x]], go right, go to state [[Q2]]
 * read [[y]]: write [[y]], stay put, go to state [[Q0]]
 * read blank: write blank, stay put, go to state [[Q6]]"
shared interface Q1 satisfies Q {}

"State after reading the first [[x]].
 This state is distinct from [[Q4]] because a single `x` is valid
 (and eventually what we end up with after repeatedly halving the number of `x`s)
 while `xxx`, for example, isn’t.
 
 Transitions:
 * read [[x]]: write [[y]], go right, go to state [[Q3]]
 * read [[y]]: write [[y]], go right, stay in this state
 * read blank: write blank, stay put, go to state [[Q6]]"
shared interface Q2 satisfies Q {}

"State when we’ve read an even number of [[x]]s.
 
 Transitions:
 * read [[x]]: write [[x]], go right, go to state [[Q4]]
 * read [[y]]: write [[y]], go right, stay in this state
 * read blank: write blank, go left, go to state [[Q5]]"
shared interface Q3 satisfies Q {}

"State when we’ve read an odd number of [[x]]s.
 
 Transitions:
 * read [[x]]: write [[y]], go right, go to state [[Q3]]
 * read [[y]]: write [[y]], go right, stay in this state
 * read blank: write blank, stay put, go to state [[Q0]]"
shared interface Q4 satisfies Q {}

"Rewind state: go back to the beginning of the word and start over.
 
 Transitions:
 * read [[x]]: write [[x]], go left, stay in this state
 * read [[y]]: write [[y]], go left, stay in this state
 * read blank: write blank, go right, go to state [[Q1]]"
shared interface Q5 satisfies Q {}

"“Accept” state. Loops forever.
 
 Transitions:
 * read anything: write it back, stay put, stay in this state"
shared interface Q6 satisfies Q {}


/* stack elements */
shared interface S of SX|SY {}
see (`value x`)
shared interface SX satisfies S {}
see (`value y`)
shared interface SY satisfies S {}

"Box around three types"
shared interface B<out A, out B, out C> { shared formal A first; shared formal B second; shared formal C third; }

shared interface Stack
        of StackHead<S, Stack>|StackEnd
        satisfies Iterable<S, Nothing> // just for the heck of it; not necessary
        { shared actual formal Stack rest; shared actual formal S first; }
shared interface StackHead<out Element, out Rest>
        satisfies Stack
        given Element satisfies S
        given Rest satisfies Stack
        { shared actual formal Rest rest; shared actual formal Element first; }
shared interface StackEnd
        satisfies Stack
        { shared actual formal Nothing rest; shared actual formal Nothing first; }

"Accepting state(s)"
shared alias Accept => B<Q6, Stack, Stack>;

/* functions */
"""State **t**ransition function for the Turing machine that, given a word composed of *n* [[x]]s, decides if *n* is a power of two.
   This means that `x`, `xx`, `xxxxxxxx` are all valid words, but `xxx` and `xxxxxx` aren’t.
   
   The machine works by repeatedly cycling over the whole word, replacing every second [[x]] with an [[y]]
   (auxiliary character; don’t use in original input word).
   
   The [[left]], [[leftRest]], [[right]], [[rightRest]] arguments are necessary for the compiler to get the types of
   [[Left]], [[LeftRest]], [[Right]] and [[RightRest]], which it can’t infer from [[state]] alone.
   You should always use `state.second.first`, `state.second.rest`, `state.third.first` and `state.third.rest` for these;
   however, that can’t be the default values, as it’s not well-typed without further knowledge of `Stack1` and `Stack2`.
   
   Usage:
   To check if *n* is a power of two, write
   ~~~
   value s00 = initial(b(x, b(x, …)));
   ~~~
   where you nest `b(x, …)` *n* times (using [[e]]`()` for the terminating “…”), then
   ~~~
   value s(N+1) = t(sN, sN.second.rest, sN.third.rest, sN.second.first, sN.third.first);
   ~~~
   with N ranging from 0 to *n* + (2*n* + 1) * log_2(*n*), and finally
   ~~~
   Accept end = s(N+1);
   ~~~
   for the last state. This is well-typed, and thus compiles, iff this turing machine is in an accepting state
   after N+1 iterations, which is the case iff *n* is a power of two.
   """
shared

State&Q0 & B<Q0, LeftStack, RightStack> |

State&Q1 & Right&SX & B<Q2, StackHead<SX, LeftStack>, RightRest> |
State&Q1 & Right&SY & B<Q0, LeftStack, RightStack> |
State&Q1 & RightStack&StackEnd & B<Q6, LeftStack, RightStack> |

State&Q2 & Right&SX & B<Q3, StackHead<SY, LeftStack>, RightRest> |
State&Q2 & Right&SY & B<Q2, StackHead<SY, LeftStack>, RightRest> |
State&Q2 & RightStack&StackEnd & B<Q6, LeftStack, RightStack> |

State&Q3 & Right&SX & B<Q4, StackHead<SX, LeftStack>, RightRest> |
State&Q3 & Right&SY & B<Q3, StackHead<SY, LeftStack>, RightRest> |
State&Q3 & RightStack&StackEnd & B<Q5, LeftRest, StackHead<Left, RightStack>> |

State&Q4 & Right&SX & B<Q3, StackHead<SY, LeftStack>, RightRest> |
State&Q4 & Right&SY & B<Q4, StackHead<SY, LeftStack>, RightRest> |
State&Q4 & RightStack&StackEnd & B<Q0, LeftStack, RightStack> |

State&Q5 & LeftStack&StackHead<Left, LeftRest> & B<Q5, LeftRest, StackHead<Left, RightStack>> |
State&Q5 & LeftStack&StackEnd & B<Q1, LeftStack, RightStack> |

State&Q6 & B<Q6, LeftStack, RightStack>

        t
        <out State, out LeftStack, out LeftRest, out RightStack, out RightRest, Left, Right>
        (B<State, LeftStack, RightStack> state, Left left, LeftRest leftRest, Right right, RightRest rightRest)
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
