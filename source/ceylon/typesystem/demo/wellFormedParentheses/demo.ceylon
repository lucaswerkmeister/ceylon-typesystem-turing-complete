void demo() {
    
    // The following statements are well-typed because (()()) is a well-formed parenthetical expression.
    
    value s0 = initial;
    value s1 = t(s0, a, s0.second.rest);
    value s2 = t(s1, a, s1.second.rest);
    value s3 = t(s2, b, s2.second.rest);
    value s4 = t(s3, a, s3.second.rest);
    value s5 = t(s4, b, s4.second.rest);
    value s6 = t(s5, b, s5.second.rest);
    Accept end = s6;
}
