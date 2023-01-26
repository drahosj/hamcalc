import std.math;

import dlangui;

//import app : global_data;

double aircoreInductance(double mDiameter, int nTurns, double mLength)
{
    double l = ((pow(mDiameter, 2) * pow(nTurns, 2))/
        ((457418 * mDiameter) + (1016127 * mLength)));
    //global_data["last_inductor"] = l;
    return l;
}

bool inductanceWindow(Window parent)
{
    auto win = Platform.instance.createWindow(
            "Inductance of Air-Core Inductor", parent);
    auto layout = parseML(q{
                TableLayout {
                    colCount: 3
                    TextWidget { text: "Diameter (m)" }
                }
            });

    return true;
}
