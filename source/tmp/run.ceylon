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
alias X => X1|X2;

/* states */
interface Q1a satisfies Qa {} interface Q1b satisfies Qb {}
interface Q2a satisfies Qa {} interface Q2b satisfies Qb {}
interface Q3a satisfies Qa {} interface Q3b satisfies Qb {}
interface Qa of Q1a|Q2a|Q3a {} interface Qb of Q1b|Q2b|Q3b {}
alias Q => Qa|Qb;
alias Accept => B<Q2a|Q2b>;

"Box around a type"
interface B<out T> {}

/* state transition functions */

S&Q1a&C&X1&B<Q1b> |
S&Q1a&C&X2&B<Q2b> |
S&Q2a&C&X1&B<Q3b> |
S&Q2a&C&X2&B<Q2b> |
S&Q3a&B<Q3b>
        a<S,C>(B<S> state, C x)
        given S of Qa
        given C of X1|X2
{ return nothing; }

S&Q1b&C&X1&B<Q1a> |
S&Q1b&C&X2&B<Q2a> |
S&Q2b&C&X1&B<Q3a> |
S&Q2b&C&X2&B<Q2a> |
S&Q3b&B<Q3a>
        b<S,C>(B<S> state, C x)
        given S of Qb
        given C of X1|X2
{ return nothing; }

"Initial state"
object initial satisfies B<Q1a> {}

shared void run() {
    // This statement is well-typed if, and only if, the word composed of the characters in it
    // (read left-to-right) is accepted by the finite state automaton encoded in a and b.
    Accept q = a(b(a(b(a(initial, x1), x1), x2), x2), x2);
}