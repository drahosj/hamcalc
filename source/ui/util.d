module ui.util;

import std.conv;
import std.stdio;

import dlangui;

T getInput(T)(Widget main, string id, T def = T.init)
{
    auto w = main.childById!EditLine(id);
    try {
        return w.text.to!T;
    } catch (ConvException) {
        return def;
    }   
}


class EditableContentChangeWrapper(T) : EditableContentChangeListener {
    T updateHandler;

    this (T _updateHandler) {
        updateHandler = _updateHandler;
    }

    void onEditableContentChanged(EditableContent source) {
        updateHandler();
    }   
}

