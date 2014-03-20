void demo() {
    
    // The following statements are well-typed because (()()) is a well-formed parenthetical expression.
    // Unfortunately, it is necessary to explicitly give the type arguments to t.
    
    value s0 = initial;
    value s1 = t<Q0, StackEnd, Nothing, A>(s0, a);
    value s2 = t<Q0, StackHead<S0, StackEnd>, StackEnd, A>(s1, a);
    value s3 = t<Q0, StackHead<S0, StackHead<S0, StackEnd>>, StackHead<S0, StackEnd>, B>(s2, b);
    value s4 = t<Q0, StackHead<S0, StackEnd>, StackEnd, A>(s3, a);
    value s5 = t<Q0, StackHead<S0, StackHead<S0, StackEnd>>, StackHead<S0, StackEnd>, B>(s4, b);
    value s6 = t<Q0, StackHead<S0, StackEnd>, StackEnd, B>(s5, b);
    Accept end = s6;
}
