module ui.inductor_ui;

import std.conv;

import dlangui;

import units;
import inductor;
import ui.util;

auto inductor_window_ml = q{
    TableLayout {
        colCount: 2
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Inductive Index (A_L)" }
            HSpacer {}
            EditLine { id: a_lInput }
        }
        HorizontalLayout {}
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Turns" }
            HSpacer {}
            EditLine { id: turnsInput }
        }
        HorizontalLayout {
            TextWidget { text: "Inductance (uH):" }
            TextWidget { id: inductanceOutput; text: "" }
        }
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Frequency (MHz)" }
            HSpacer {}
            EditLine { id: frequencyInput }
        }
        HorizontalLayout {
            TextWidget { text: "Reactance (ohms):" }
            TextWidget { id: reactanceOutput; text: "" }
        }
        HorizontalLayout {}
        HorizontalLayout {
            TextWidget { text: "Resonant capacitance (nF):" }
            TextWidget { id: capacitanceOutput; text: "" }
        }
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Desired Inductance (uH)" }
            HSpacer {}
            EditLine { id: inductanceInput }
        }
        Button { id: solveFromInductance; text: "Solve" }
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Desired Reactance (ohms)" }
            HSpacer {}
            EditLine { id: reactanceInput }
        }
        Button { id: solveFromReactance; text: "Solve" }
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Capacitance (nF)" }
            HSpacer{}
            EditLine { id: capacitanceInput }
        }
        HorizontalLayout {
            TextWidget { text: "Resonant frequency (MHz):" }
            TextWidget { id: frequencyOutput; text: "" }
        }
        HorizontalLayout { 
            TextWidget { text: "Solve Inductor from Capacitor" }
        }
        Button { id: solveFromFrequency; text: "Solve" }
    }
};


void updateInductance(Widget main)
{
    auto a_l = main.getInput!double("a_lInput");
    auto turns = main.getInput!double("turnsInput");

    auto newL = ToroidInductance(a_l, turns);

    main.childById!TextWidget("inductanceOutput").text =
        newL.microhenries.to!dstring;

    auto f = getInput!double(main, "frequencyInput").megahertz;
    auto newX_L = InductiveReactance(newL, f);
    auto newC = ResonantCapacitance(newL, f);
    main.childById!TextWidget("reactanceOutput").text = newX_L.johms.to!dstring;
    main.childById!TextWidget("capacitanceOutput").text = 
        newC.nanofarads.to!dstring;

    auto inputC = getInput!double(main, "capacitanceInput").nanofarads;
    auto resF = ResonantFrequency(newL, inputC);
    main.childById!TextWidget("frequencyOutput").text = 
        resF.megahertz.to!dstring;
}

void solveInductance(Widget main)
{
    auto a_l = getInput!double(main, "a_lInput");
    auto targetL = getInput!double(main, "inductanceInput").microhenries;
    auto turns = ToroidTurns(targetL, a_l);

    main.childById!EditLine("turnsInput").text = turns.to!dstring;
}

void solveReactance(Widget main)
{

    auto a_l = getInput!double(main, "a_lInput");
    auto f = getInput!double(main, "frequencyInput").megahertz;
    auto targetX = getInput!double(main, "reactanceInput").johms;

    auto turns = ToroidTurns(targetX, f, a_l);

    main.childById!EditLine("turnsInput").text = turns.to!dstring;
}

void solveFrequency(Widget main)
{
    auto f = main.getInput!double("frequencyInput").megahertz;
    auto c = main.getInput!double("capacitanceInput").nanofarads;

    auto x_l = ResonantInductance(c, f);

    main.childById!EditLine("inductanceInput").text = 
        x_l.microhenries.to!dstring;
}

bool showInductorWindow(Window mainWin)
{
    auto win = Platform.instance.createWindow("Inductor Calc", mainWin);   
    win.mainWidget = parseML(inductor_window_ml);
    auto mw = win.mainWidget;

    static foreach(id; [
            "a_lInput", 
            "turnsInput", 
            "frequencyInput",
            "capacitanceInput"
    ]) {
        mw.childById!EditLine(id).contentChange = 
            new EditableContentChangeWrapper!(void delegate())(delegate() {
                updateInductance(mw);
        });
    }

    mw.childById!Button("solveFromInductance").click = delegate(Widget w) {
        solveInductance(mw);
        return true;
    };
    mw.childById!Button("solveFromReactance").click = delegate(Widget w) {
        solveReactance(mw);
        return true;
    };
    mw.childById!Button("solveFromFrequency").click = delegate(Widget w) {
        solveFrequency(mw);
        solveInductance(mw);
        return true;
    };
    win.show();
    return true;
}
