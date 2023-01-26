import std.complex;
import std.math;

template QuantityPrefix(
        string quantity, string unit, string prefix, string power, B)
{
    const char[] QuantityPrefix =
        quantity ~ " " ~ prefix ~ unit ~ "(" ~ B.stringof ~ " x) { return " ~ 
        quantity ~ "(x * 1e" ~ power ~ "); }" ~ 
        B.stringof ~" " ~ prefix ~ unit ~ "(" ~ quantity ~ 
        " x) { return x / 1e" ~ power ~ "; }";
}

template QuantityType(string quantity, string unit, B)
{
    const char[] QuantityType = 
        "struct " ~ quantity ~ " { " ~ B.stringof ~ " " ~ unit ~ "; alias " ~
        unit ~ " this; };";
}

mixin template CommonPrefixes(string quantity, string unit, B) 
{
    mixin(QuantityPrefix!(quantity, unit, "giga", "9", B));
    mixin(QuantityPrefix!(quantity, unit, "mega", "6", B));
    mixin(QuantityPrefix!(quantity, unit, "kilo", "3", B));
    mixin(QuantityPrefix!(quantity, unit, "", "0", B));
    mixin(QuantityPrefix!(quantity, unit, "milli", "-3", B));
    mixin(QuantityPrefix!(quantity, unit, "micro", "-6", B));
    mixin(QuantityPrefix!(quantity, unit, "nano", "-9", B));
}

mixin template Quantity(string quantity, string unit, B)
{
    mixin(QuantityType!(quantity, unit, B));
    mixin CommonPrefixes!(quantity, unit, B);
}

mixin Quantity!("Inductance", "henries", double);
mixin Quantity!("Frequency", "hertz", double);
mixin Quantity!("Resistance", "ohms", double);
mixin Quantity!("Reactance", "johms", double);
mixin Quantity!("Capacitance", "farads", double);

struct Impedance {
    Complex!double ohms;
    alias ohms this;

    this (Resistance r, Reactance i)
    {
        this(Complex!double(r.ohms, i.johms));
    }
    
    this (Complex!double c) {
        ohms = c;
    }
}

mixin CommonPrefixes!("Impedance", "ohms", Complex!double);

double rad_s(Frequency f)
{
    return 2 * PI * f.hertz;
}

Frequency rad_s(double f)
{
    return (f / (2 * PI)).hertz;
}

unittest {
    static assert(is(typeof(200.megahertz) == Frequency));
    static assert(is(typeof(200.nanohenries) == Inductance));
    static assert(is(typeof(200.nanohenries.microhenries) == double));
    static assert(is(typeof(200.nanohenries) == Inductance));
    static assert(is(typeof(200.ohms) == Resistance));

    bool floatCompare(T)(T a, T b)
    {
        return(abs(a - b) < 1e-15);
    }

    assert(floatCompare(200000.nanohenries, 200.microhenries));
    assert(!floatCompare(200000.nanohenries, 201.microhenries));
    assert(200000.nanohenries.henries == 200e-6);
}
