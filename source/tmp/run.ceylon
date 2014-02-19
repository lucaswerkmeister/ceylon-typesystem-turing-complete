/*
   Simulate the automaton
   
       x2     x1
   →q1---->q2---->q3
    ↻      ↻      ↻
    x1     x2     x1,x2
   
   with accepting state q2. This automaton recognizes the language x1*x2x2*.
 */

/* alphabet */
abstract class X1() of x1 {} object x1 extends X1() {}
abstract class X2() of x2 {} object x2 extends X2() {}

/* states */
interface Q of Q1|Q2|Q3 {}
interface Q1 satisfies Q {}
interface Q2 satisfies Q {}
interface Q3 satisfies Q {}

"Box around a type"
interface B<out T> {}

"Accepting state(s)"
alias Accept => B<Q2>;

"Initial state"
object initial satisfies B<Q1> {}

"State transition function"
S&Q1&C&X1&B<Q1> |
S&Q1&C&X2&B<Q2> |
S&Q2&C&X1&B<Q3> |
S&Q2&C&X2&B<Q2> |
S&Q3&C&X1&B<Q3> |
S&Q3&C&X2&B<Q3>
        t<S,C>(B<S> state, C x)
        given S of Q
        given C of X1|X2
{ return nothing; }

shared void run() {
    // This statement is well-typed if, and only if, the word composed of the characters in it
    // (read left-to-right) is accepted by the finite state automaton encoded in t.
    Accept q = t(t(t(t(t(initial, x1), x1), x2), x2), x2);
}