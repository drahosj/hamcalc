import std.math;

import units;

Inductance ToroidInductance(double a_l, double turns)
{
    return (a_l*pow(turns, 2)).nanohenries;
}

double ToroidTurns(Inductance l, double a_l)
{
    return round(sqrt(l.nanohenries/a_l));
}

double ToroidTurns(Reactance x_l, Frequency f, double a_l)
{
    return ToroidTurns(InductanceForReactance(x_l, f), a_l);
}

Reactance InductiveReactance(Inductance l, Frequency f)
{
    return (f.rad_s * l.henries).johms;
}

Inductance InductanceForReactance(Reactance x_l, Frequency f)
{
    return (x_l.johms / f.rad_s).henries;
}

Reactance ToroidReactance(double a_l, double turns, Frequency f)
{
    return InductiveReactance(ToroidInductance(a_l, turns), f);
}

Capacitance ResonantCapacitance(Inductance l, Frequency f)
{
    return (1.0 / (pow(f.rad_s, 2) * l.henries)).farads;
}

Inductance ResonantInductance(Capacitance c, Frequency f)
{
    return (1.0 / (pow(f.rad_s, 2) * c.farads)).henries;
}

Frequency ResonantFrequency(Inductance l, Capacitance c)
{
    return (1.0/sqrt(l.henries * c.farads)).rad_s;
}

unittest {
    import std.stdio;
    writeln("A_L = 11 nH/turns^2");
    writefln("\t5 turns: %s uH", ToroidInductance(11, 5).microhenries);
    assert(ToroidTurns(275.nanohenries, 11) != 4);
    assert(ToroidTurns(275.nanohenries, 11) == 5);
    assert(ToroidTurns(275.nanohenries, 11) != 6);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(11, 5, 7.megahertz));
    assert(ToroidTurns(12.johms, 7.megahertz, 11) != 4);
    assert(ToroidTurns(12.johms, 7.megahertz, 11) == 5);
    assert(ToroidTurns(12.johms, 7.megahertz, 11) != 6);
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(11, 5, 14.megahertz));
    assert(ToroidTurns(24.johms, 14.megahertz, 11) == 5);
    writefln("\t10 turns: %s uH", ToroidInductance(11, 10).microhenries);
    assert(ToroidTurns(1.1.microhenries, 11) == 10);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(11, 10, 7.megahertz));
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(11, 10, 14.megahertz));
    writefln("\t12 turns: %s uH", ToroidInductance(11, 12).microhenries);
    assert(ToroidTurns(1.58.microhenries, 11) == 12);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(11, 12, 7.megahertz));
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(11, 12, 14.megahertz));
    writeln();
    writeln("A_L = 885 nH/turns^2");
    writefln("\t5 turns: %s uH", ToroidInductance(885, 5).microhenries);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(885, 5, 7.megahertz));
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(885, 5, 14.megahertz));
    writefln("\t10 turns: %s uH", ToroidInductance(885, 10).microhenries);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(885, 10, 7.megahertz));
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(885, 10, 14.megahertz));
    writefln("\t12 turns: %s uH", ToroidInductance(885, 12).microhenries);
    writefln("\t\t 7 MHz: %sj ohms", ToroidReactance(885, 12, 7.megahertz));
    writefln("\t\t 14 MHz: %sj ohms", ToroidReactance(885, 12, 14.megahertz));

    writeln();
    writeln("Turns required for 500j ohms on T130-1 (A_L=20 nH/t^2))");
    writefln("\t 7 MHz: %s turns", ToroidTurns(500.johms, 7000.kilohertz, 20));
    writefln("\t 14 MHz: %s turns", ToroidTurns(500.johms, 14.megahertz, 20));
    writefln("\t 28 MHz: %s turns", ToroidTurns(500.johms, 28.megahertz, 20));

    writeln();
    writeln("Inductance and 10/20/40m reactance for # turns:");
    foreach(i; 12..24) {
        writefln("%s Turns:\t%s uH\t%sj/%sj/%sj ohms",
            i,
            ToroidInductance(20, i).microhenries,
            ToroidReactance(20, i, 28.megahertz).johms,
            ToroidReactance(20, i, 24.megahertz).johms,
            ToroidReactance(20, i, 7.megahertz).johms);
    }

    writeln();
    writefln("Capacitor to resonate 20 nH inductor at 14 MHz (nF): %s",
            20.nanohenries.ResonantCapacitance(14.megahertz).nanofarads);
    writefln("Capacitor to resonate 20 nH inductor at 7 MHz (nF): %s",
            20.nanohenries.ResonantCapacitance(7.megahertz).nanofarads);
}
