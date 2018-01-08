
import dlangui;

import jmisc;

import control, taskman;

struct Gui {
private:
	Window _window;
	EditBox _editBoxMain;
    TaskMan _taskMan;
    Control _control;

    //bool _waiting;
    string _input;
public:
    auto getInput() {
        return _input;
    }

    //void waiting(bool waiting0) { _waiting = waiting0; }
    //auto waiting() { return _waiting; }

	int setup(ref TaskMan taskMan) {
        _taskMan = taskMan;
        _control.setup(_taskMan);
		_window = Platform.instance.createWindow(
			"GUI TimeLog Program", null, WindowFlag.Resizable, 1280, 800);

		// Crease widget to show in window
		_window.mainWidget = parseML(q{
			VerticalLayout {
				margins: 3
				padding: 3
				EditBox {
					id: editBoxMain
					minWidth: 640; minHeight: 700; maxHeight: 640;
				}

				Button { id: buttonActivate; maxWidth: 100; text: "- Activate Last Line -" }
			}
		});

		_editBoxMain = _window.mainWidget.childById!EditBox("editBoxMain");
		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
            import std.string: lastIndexOf;
			import std.conv: to;

            auto i = _editBoxMain.text.to!string.lastIndexOf("\n") + 1;
            _input = _editBoxMain.text[i .. $].to!string;
            (`"` ~ _input ~ `"`).gh;
            //waiting = true;            _input.gh;
            auto output = _control.processInput(_input);
            if (output.length > 0)
                _editBoxMain.text = _editBoxMain.text ~ (output ~ "\n").to!dstring;

            return true;
		};

		_editBoxMain.text = "Insert 'h' at the bottom line,\n" ~
			"then press the Activate button for help\n".to!dstring;

		_window.show();

		return 0;
    }
}