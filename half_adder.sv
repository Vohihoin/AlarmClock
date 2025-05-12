module half_adder(
    input A,
    input B,
    output S,
    output Cout
);

    xor iXOR(S, A, B);
    and iAND(Cout, A, B);

endmodule