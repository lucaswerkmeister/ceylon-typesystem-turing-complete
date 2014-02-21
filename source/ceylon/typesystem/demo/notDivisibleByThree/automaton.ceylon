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
shared interface Q0 satisfies Q {}
shared interface Q1 satisfies Q {}
shared interface Q2 satisfies Q {}

"Box around a type"
shared interface B<out T> {}

"Accepting state(s)"
shared alias Accept => B<Q1|Q2>;

"Initial state"
shared object initial satisfies B<Q0> {}

shared alias R0 => X0|X3|X6|X9;
shared alias R1 => X1|X4|X7;
shared alias R2 => X2|X5|X8;

"""State transition function for the automaton
   ~~~
      0,3,6,9               0,3,6,9
         ↻        1,4,7        ↻
        q0––––––––––––––––––––→q1
        ↖ \←––––––––––––––––––↗ /
         \ \                 / /
          \ \               / /
           \ \    2,5,8    / /
      1,4,7 \ \           / / 1,4,7
             \ \         / /
              \ \       / /
               \ \     / /
                \ \   / /
                 \ ↘ / ↙
                   q2
                   ↻
                0,3,6,9
   ~~~
   (Markdown doesn’t like the ASCII art, look at the source code instead)
   with accepting states q1 and q2, which accepts decimal representations of numbers _not_ divisible by three.
   
   Usage:
   
   Accept q = t(t([[initial]], [[_1]]), [[_3]]);
   
   to test if the number 13 is not divisible by 3.
   This statement is well-typed iff the word is in the language.
   """
shared
S&Q0&C&R0&B<Q0> |
S&Q0&C&R1&B<Q1> |
S&Q0&C&R2&B<Q2> |
S&Q1&C&R0&B<Q1> |
S&Q1&C&R1&B<Q2> |
S&Q1&C&R2&B<Q0> |
S&Q2&C&R0&B<Q2> |
S&Q2&C&R1&B<Q0> |
S&Q2&C&R2&B<Q1>
        t<S,C>(B<S> state, C x)
        given S of Q
        given C of X0|X1|X2|X3|X4|X5|X6|X7|X8|X9
{ return nothing; }
