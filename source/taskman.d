//#how did the goto get here?
//#new
//#Possible tasks
//#cannot understand the next two resualts
//#don't know why it works
//#not try catch
//# set new done tasks
module taskman;

private {
	import std.stdio;
	import core.stdc.stdio;
	import std.string;
//	import std.date;
	import std.datetime;
	import std.file: FileException;
	import std.algorithm;

//	import terminal;
	import jtask.taskmanbb, jtask.basebb;
	import base, task;
}

struct TaskMan {
private:
	Task[] _possibleTasks, // possible tasks are the tasks you choose from
		_doneTasks; // done tasks are the tasks that you have done
	int _selectedTaskIndex; // or gotten task to go with 'g' at command module
	//#Possible tasks
	struct TaskHidden {
		int tagNumber;
		string tagName;
		
		this( int tagNumber, string tagName ) {
			this.tagNumber = tagNumber;
			this.tagName = tagName;
		}
	}
	TaskHidden[] tasksHidden;
	string _cformat; // custom format
	string _textTank;
public:
	@property {
		string textTank() { return _textTank; }
		void textTank(string textTank0) { _textTank = textTank0; }
		string cformat() { return _cformat; }
	}

	void listFoundText(in string phrase) {
		int numberOfItem = 1; //#redundant, why not use cast(int)(i + 1)
		
		foreach ( i, task; _doneTasks ) {
			if ( std.string.indexOf(task.comment(), phrase) != -1 ) {
				_textTank ~= task.viewInfo( numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
				numberOfItem++;
			}
		}
	}

	string printDay(int fd, int fm, int fy, int tod = 0, int tom = 0, int toy = 0) {
		import std.range;

		string result;
		
		int numberOfItem = 1;
		bool found = false;
		bool last = false;
		int id, im, iy;

		id=fd;
		im=fm;
		iy=fy;
		if (tod != 0)
			while(true) { // while
				foreach(i, task; _doneTasks)
						with(task.dateTime)
							if (day == id && month == im && year == iy) {
								immutable info = task.viewInfo(
									numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
								_textTank ~= info;
								result ~= info;
								numberOfItem++;
								found = true;
							}

				id++;
				if (id > 31) {
					id = 0;
					im++;
					if (im>12) {
						im = 0;
						iy++;
					}
				}
				if (last)
					break;
				if (id == tod && im == tom && iy == toy)
					last = true; //#how did the goto get here?
			} // while

		if (tod == 0)
			foreach(i, task; _doneTasks) {
				with(task.dateTime)
					if (day == fd && month == fm && year == fy) {
						immutable info = task.viewInfo(
							numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
						_textTank ~= info;
						result ~= info;
						numberOfItem++;
						found = true;
					}
			}

		if (! found)
			result = "No results!";
		
		return result;
	} // printDay

	void saveTextTank(string fileName) {
		immutable fileWrite = "w";

		File(fileName, fileWrite).write(_textTank);
	}

	void resetCategorys() {
		_possibleTasks.length = 0;
	}

	void clearHidden() {
		tasksHidden.length = 0;
	}
	
	void showHiddenCategorys() {
		foreach(taskh; tasksHidden)
			with(taskh)
				writefln("%03s %s", tagNumber, tagName);
	}

	/// return: the number of possible tasks
	size_t getNumberOfPossibleTasks()
	{
		return _possibleTasks.length;
	}
	
	/// set the time of day
	void setTime(int hour, int minute,int second) {
		_doneTasks[ _selectedTaskIndex ].setTime(hour, minute, second);
	}

	/// set the end time of day
	void setEndTime(int hour, int minute,int second) {
		_doneTasks[ _selectedTaskIndex ].setEndTime(hour, minute, second);
	}

	bool noPossibleTasks()
	{
		return _possibleTasks.length == 0;
	}

	size_t numberOfTasks()
	{
		return _doneTasks.length;
	}

	void addPossible(Task possibleTask)
	{
		_possibleTasks ~= possibleTask;
	}

	void opOpAssign(string op)(Task doneTask)
		if (op == "~")
	{
		_doneTasks ~= doneTask;
	}

	Task getPossibleTask(int index) {
		if ( index >= 0 && index < _possibleTasks.length )
			return _possibleTasks[index];
		else {
			//writecln( Color.red, "You are in error!" );
			writeln("taskman.d - Task getPossibleTask(int index) - getPossibleTask out of bounds!");
			return null;
		}
	}
	
	void saveHidden(in string fileName) {
		import std.file;

		immutable fileWriteOnly = "w";
		auto f = File(fileName, fileWriteOnly);

		foreach(taskh; tasksHidden)
			f.writefln("%03s %s", taskh.tagNumber, taskh.tagName);

		f.close();
	}
	

	Task getTask(in int index)
	{
		if ( index < 0 || index > _doneTasks.length)
		{
			writeln("Task getTask" ~ "(immutable int index)" ~ " - out of bounds (", index, ")");
			return null;
		}
			
		return _doneTasks[index];
	}
	
	void setTaskIndex(in int index)
	{
		if ( index < 0 || index > _doneTasks.length)
		{
			writeln("value for index is out of bounds in _doneTasks. (", index, ")");
			return;
		}
		_selectedTaskIndex = index;
	}
	
	/// set time length for task
	void setTimeLength( TimeLength tl )
	{
		_doneTasks[ _selectedTaskIndex ].setTimeLength( tl );
	}
	
	/// set date
	void setDate(int date, int month, int year) {
		_doneTasks[_selectedTaskIndex].setDate(date, month, year);
	}
	
	/// Add some thing said about the log entry (eg. comment)
	void setComment(string comment)
	{
		_doneTasks[_selectedTaskIndex].setComment(comment);
	}
	
	void viewLast() {
		if ( _doneTasks.length > 0 )
			writefln("%2s - %-40s",
					_doneTasks[$-1].id, _doneTasks[$-1].taskString);
	}
	
	/// Sort list by date and time
	void doSort() {
		sort!("a.getDateTime() < b.getDateTime()")(_doneTasks);
	}
	
	//#new
	void customFormatList(string cformat) {
		_cformat = cformat;
	}
	
	void convertToCommands(string fileName) {
		string content;
		foreach ( i, task; _doneTasks ) {
			with(task) {
				content ~= format("%s\n%s\n",
								  catagoryToCommand(),
								  dateToCommand());
				if (comment != "")
					content ~= commentToCommand() ~ "\n";

				if (timeLength != TimeLength(0,0,0))
					content ~= lengthToCommand() ~ "\n";

				if (displayTimeFlag)
					content ~= timeToCommand() ~ "\n";

				if (displayEndTimeFlag)
					content ~= endTimeToCommand() ~ "\n";
			}
		}
		File(fileName, "w").write(content);
		//auto f = File(fileName, "w"); // open for writing
		//f.write(content);
		//f.close;
	}
	
	/// View all possible tasks
	void view( TaskType taskType, int format = 0 ) {
		auto tasks = [_possibleTasks, _doneTasks, _doneTasks][taskType];
		final switch ( taskType )
		{
			case TaskType.possibles:
				bool isHidden( string testTask ) {
					foreach( taskString; tasksHidden )
						if ( testTask == taskString.tagName )
							return true;
					return false;
				}
				//#this does not help for not displaying the possible tasks
				Task[] displayTasks;
				int[] index;
				foreach( i, t; tasks )
					if ( t.taskString != "<skip>" && !isHidden( t.taskString ) ) {
						displayTasks ~= t;
						index ~= cast(int)i;
					}

				//#cannot understand the next two resualts
				//mixin( trace( "displayTasks.length" ) );
				//mixin( trace( "tasks.length" ) );
				switch(format) {
					default: break;
					case 0:
						bool isDevOfTwo() { return displayTasks.length % 2; }
						foreach ( i; 0 .. displayTasks.length / 2 + ( isDevOfTwo ? 1 : 0 ) ) {
							displayTasks[ i ].viewInfo(
								0,
								index[i],
								Collum.left,
								TaskType.possibles
							); // left
							if ( displayTasks.length / 2 + i < tasks.length )
								displayTasks[ cast(uint)displayTasks.length / 2 + i ].viewInfo(
									0, cast(int)displayTasks.length / 2 + cast(int)i, Collum.right, TaskType.possibles ); // right
							else
								writeln();
						}
					break;
					case 1:
						foreach(i; 0 .. displayTasks.length) {
							displayTasks[i].viewInfo(
								0,
								index[i],
								Collum.left, // ?
								TaskType.possibles
							);
							writeln();
						}
					break;
				}
			break;
			case TaskType.done:
				int offSet = tasks.length > 30 ? cast(int)tasks.length - 30 : 0;
				foreach ( i, task; tasks[ offSet .. $ ] )
				{
					_textTank ~= task.viewInfo( cast(int)i, offSet + cast(int)i, Collum.straitDown, TaskType.done, _cformat );
				}
			break;
			case TaskType.allDone:
				foreach(i, task; tasks) {
					_textTank ~= task.viewInfo( cast(int)i, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
				}
			break;
		}
	}
	
	/// I/O output
	void saveToTextFile( in string fileName )
	{
		string content;
		foreach ( i, task; _doneTasks )
		{
			content ~= task.doneString( 0, cast(int)i ) ~ '\n';
		}
		auto f = File( fileName, "w"); // open for writing
		f.write( content );
		f.close;
	}
	
	/// remove from the done tasks list
	void removeAt(int index)
	{
		if ( index < _doneTasks.length && index >= 0 )
		{
			write("Deleting (enter 'ld' to revert to last save) - "); _doneTasks[index].viewInfo(0, index, TaskType.done);
			_doneTasks = _doneTasks[0 .. index] ~ _doneTasks[index + 1 .. $];
		}
		else
		{
			writeln("That, my friend, is an invalid number.");
		}
	}
	
//		void viewInfo( int indexNumber, int collum, TaskType taskType = TaskType.possibles )

	/// List just by the selected type (eg. 'got up', but its number)
	void listByType( int typeId, string cformat )
	{
		int numberOfItem = 1;

		foreach ( i, task; _doneTasks )
		{
			if ( task.id == typeId )
			{
				_textTank ~= task.viewInfo( numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
				numberOfItem++;
			}
		}
	}

	void clearDoneTasks()
	{
		_doneTasks.length = 0;
	}
	
	void saveDoneTasks(string filename)
	{
		TaskManbb tmbb;
		//	this( int  id, string taskString, TimeLength length0, string comment, DateTime dateTime,
//		  bool displayTimeFlag ) {

		// loop through all the tasks and add them to tmbb.tasksbb
		foreach( task; _doneTasks ) {
			scope( failure ) {
				writeln( "id: ", task.id );
			}
			with( task ) {
				tmbb.tasksbb ~= new Taskbb( id, _possibleTasks[ id ].taskString, timeLength, comment,
					                        dateTime, displayTimeFlag, endTime, displayEndTimeFlag );
			}
		}
		tmbb.saveDoneTasksbb( filename );
	}
	
	/// Load tasks that are done
	void loadDoneTasks(string filename) {
		_doneTasks.length = 0;
		TaskManbb tmbb;
		tmbb.loadDoneTasksbb( filename );
		foreach( taskbb; tmbb.tasksbb ) {
			with( taskbb )
				_doneTasks ~= new Task( id, taskString, timeLength, comment
				, dateTime, displayStartTimeFlag
				, endTime, displayEndTimeFlag );
		}
	}
	
	//#Possible tasks
	void addHidden( int tagNumber, string tagName ) {
		tasksHidden ~= TaskHidden( tagNumber, tagName );
	}
}
