void demo() {
    // This statement is well-typed if, and only if, the word composed of the characters in it
    // (read left-to-right) is accepted by the finite state automaton encoded in t.
    Accept q = t(t(t(t(t(initial, a), a), b), b), b);
}
