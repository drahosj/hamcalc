module ui;

import std.conv;

import dlangui;

import units;
import inductor;

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
            TextWidget { id: inductanceOutput; text: "N/A" }
        }
        HorizontalLayout {
            layoutWidth: FILL_PARENT
            TextWidget { text: "Frequency (MHz)" }
            HSpacer {}
            EditLine { id: frequencyInput }
        }
        HorizontalLayout {
            TextWidget { text: "Reactance (ohms):" }
            TextWidget { id: reactanceOutput; text: "N/A" }
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
    }
};


T getInput(T)(Widget main, string id, T def = T.init)
{
    auto w = main.childById!EditLine(id);
    try {
        return w.text.to!T;
    } catch (ConvException) {
        w.text = def.to!dstring;
        return T.init;
    }
}

void updateInductance(Widget main)
{
    auto a_l = getInput!double(main, "a_lInput", 0);
    auto turns = getInput!double(main, "turnsInput", 0);

    auto newL = ToroidInductance(a_l, turns);

    main.childById!TextWidget("inductanceOutput").text =
        newL.microhenries.to!dstring;

    auto f = getInput!double(main, "frequencyInput", 0).megahertz;
    auto newX_L = InductiveReactance(newL, f);
    main.childById!TextWidget("reactanceOutput").text = newX_L.johms.to!dstring;

}

void solveInductance(Widget main)
{
    auto a_l = getInput!double(main, "a_lInput", 0);
    auto targetL = getInput!double(main, "inductanceInput").microhenries;
    auto turns = ToroidTurns(targetL, a_l);

    main.childById!EditLine("turnsInput").text = turns.to!dstring;
}

void solveReactance(Widget main)
{

    auto a_l = getInput!double(main, "a_lInput", 0);
    auto f = getInput!double(main, "frequencyInput", 0).megahertz;
    auto targetX = getInput!double(main, "reactanceInput").johms;

    auto turns = ToroidTurns(targetX, f, a_l);

    main.childById!EditLine("turnsInput").text = turns.to!dstring;
}

class UpdateWrapper : EditableContentChangeListener {
    void delegate() updateHandler;

    this (void delegate() _updateHandler) {
        updateHandler = _updateHandler;
    }

    void onEditableContentChanged(EditableContent source) {
        updateHandler();
    }
}

bool showInductorWindow(Window mainWin)
{
    auto win = Platform.instance.createWindow("Inductor Calc", mainWin);   
    win.mainWidget = parseML(inductor_window_ml);
    auto mw = win.mainWidget;
    auto wrapper = new UpdateWrapper(delegate() {
            updateInductance(mw);
    });

    mw.childById!EditLine("a_lInput").contentChange = wrapper;
    mw.childById!EditLine("turnsInput").contentChange = wrapper;
    mw.childById!EditLine("frequencyInput").contentChange = wrapper;

    mw.childById!Button("solveFromInductance").click = delegate(Widget w) {
        solveInductance(mw);
        return true;
    };
    mw.childById!Button("solveFromReactance").click = delegate(Widget w) {
        solveReactance(mw);
        return true;
    };
    win.show();
    return true;
}
