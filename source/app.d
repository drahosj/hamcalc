import std.stdio;

import dlangui;

import ui.inductor_ui;

mixin APP_ENTRY_POINT;

double[string] global_data;

auto main_window_ml = q{
    VerticalLayout {
        Button { id: inductor; text: "Inductor Calc" }
    }
};

extern (C) int UIAppMain(string[] args) {
    string[] resourceDirs = [
        appendPath(exePath, "../res/")
    ];

    Platform.instance.resourceDirs = resourceDirs;
    Platform.instance.uiLanguage = "en";

    Window window = Platform.instance.createWindow("Hamcalc", null);

    auto layout = parseML(main_window_ml);

    layout.childById("inductor").click = delegate(Widget w) {
        return showInductorWindow(window);
    };
    window.mainWidget = layout;

    window.show();

    return Platform.instance.enterMessageLoop();
}
