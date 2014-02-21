/* alphabet */
shared abstract class X1() of a {} shared object a extends X1() {}
shared abstract class X2() of b {} shared object b extends X2() {}

/* states */
shared interface Q of Q1|Q2|Q3 {}
shared interface Q1 satisfies Q {}
shared interface Q2 satisfies Q {}
shared interface Q3 satisfies Q {} // “trash” state

"Box around a type"
shared interface B<out T> {}

"Accepting state(s)"
shared alias Accept => B<Q2>;

"Initial state"
shared object initial satisfies B<Q1> {}

"State transition function for the automaton
 ~~~
     a     a
 →q1--->q2--->q3
  ↻     ↻     ↻
  a     b     a,b
 ~~~
 with accepting state q2. (This automaton recognizes the language `a*bb*`.)
 
 Usage:
 
 Accept q = t(t([[initial]], [[a]]), [[b]]);
 
 to test if the word `ab` is in the language recognized by the above automaton.
 This statement is well-typed iff the word is in the language.
 "
shared
S&Q1&C&X1&B<Q1> | // when in state Q1 and reading character x1, stay in state Q1
S&Q1&C&X2&B<Q2> | // when in state Q1 and reading character x2, go to state Q2
S&Q2&C&X1&B<Q3> | // when in state Q2 and reading character x1, go to state Q3
S&Q2&C&X2&B<Q2> | // when in state Q2 and reading character x2, stay in state Q2
S&Q3&C&X1&B<Q3> | // when in state Q3 and reading character x1, stay in state Q3
S&Q3&C&X2&B<Q3>   // when in state Q3 and reading character x2, stay in state Q3
// the two Q3 transitions could also be combined as
// S&Q3&B<Q3>
        t<S,C>(B<S> state, C x)
        given S of Q
        given C of X1|X2
{ return nothing; }
