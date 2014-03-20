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
shared interface P<out T, out S> { shared formal T first; shared formal S second; }

shared interface Stack
        of StackHead|StackEnd
        { shared formal Stack rest; }
shared interface StackHead<out Element=S0, out Rest=Stack>
        satisfies Stack
        given Element satisfies S
        given Rest satisfies Stack
        { shared actual formal Rest rest; }
shared interface StackEnd
        satisfies Stack
        { shared actual formal Nothing rest; }

"Accepting state(s)"
shared alias Accept => P<Q0, StackEnd>;

"Initial state"
shared object initial satisfies P<Q0, StackEnd> { shared actual Q0 first = nothing; shared actual StackEnd second = nothing; }

"""State transition function for the pushdown automaton
   ~~~
   a,ε,s0
   b,s0,ε
   ↻
   ~~~
   which accepts correct parenthetical statements ([[a]] being `(` and [[b]] being `)`) by empty stack.
   
   The [[rest]] argument is necessary for the compiler to get the type of RestStak, which it can’t infer from [[state]] alone.
   You should always use `state.second.rest` for this; however, this can’t be the default value,
   as it’s not well-typed without further knowledge of `Stak`.
   
   Usage:
   ~~~
   value s0 = initial;
   value s1 = t(s0, a, s0.second.rest);
   value s2 = t(s1, b, s1.second.rest);
   Accept end = s2;
   ~~~
   to check if the word `ab` is in the language accepted by this automaton.
   """
shared
C&A&P<Q0,StackHead<S0, Stak>> |
C&B&Stak&StackHead<S0, RestStak>&P<Q0, RestStak>
        t<out Stat, out Stak, out RestStak, C>(P<Stat, Stak> state, C x, RestStak rest)
        given Stat satisfies Q
        given RestStak satisfies Stack
        given Stak of StackEnd|StackHead<S0, RestStak>
                   satisfies Stack
        given C of A|B
{ return nothing; }
