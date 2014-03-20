/* alphabet */
shared abstract class A() of a {} shared object a extends A() {}
shared abstract class B() of b {} shared object b extends B() {}

/* states */
shared interface Q of Q0 {}
shared interface Q0 satisfies Q {}

/* stack elements */
shared interface S of S0 {}
shared interface S0 satisfies S {}

"Pair of two types"
shared interface P<out T, out S> {}

shared interface Stack
        of StackHead|StackEnd
        {}
shared interface StackHead<out Element=S0, out Rest=Stack>
        satisfies Stack
        given Element satisfies S
        given Rest satisfies Stack
        {}
shared interface StackEnd
        satisfies Stack
        {}

"Accepting state(s)"
shared alias Accept => P<Q0, StackEnd>;

"Initial state"
shared object initial satisfies P<Q0, StackEnd> {}

"""State transition function for the pushdown automaton
   ~~~
   a,ε,s0
   b,s0,ε
   ↻
   ~~~
   which accepts correct parenthetical statements ([[a]] being `(` and [[b]] being `)`) by empty stack.
   
   Usage: see demo.ceylon. You need to explicitly specify the type arguments.
   """
shared
C&A&P<Q0,StackHead<S0, Stak>> |
C&B&Stak&StackHead<S0, RestStak>&P<Q0, RestStak>
        t<out Stat, out Stak, out RestStak, C>(P<Stat, Stak> state, C x)
        given Stat satisfies Q
        given RestStak satisfies Stack
        given Stak of StackEnd|StackHead<S0, RestStak>
                   satisfies Stack
        given C of A|B
{ return nothing; }
