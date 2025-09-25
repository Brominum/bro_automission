_logic = _this select 0;
disableSerialization;
private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
private _background = _display ctrlCreate ["RscText", 1000];
	_background ctrlSetPosition [0.3, 0.2, 0.4, 0.7];
	_background ctrlSetBackgroundColor [0,0,0,0.7];
	_background ctrlCommit 0;
private _factionLabel = _display ctrlCreate ["RscText", 1001];
	_factionLabel ctrlSetText "Faction to spawn:";
	_factionLabel ctrlSetPosition [0.31, 0.21, 0.38, 0.05];
	_factionLabel ctrlSetBackgroundColor [0,0,0,0];
	_factionLabel ctrlSetTextColor [1,1,1,1];
	_factionLabel ctrlCommit 0;
private _listbox = _display ctrlCreate ["RscListbox", 1500];
	_listbox ctrlSetPosition [0.32, 0.26, 0.36, 0.35];
	_listbox ctrlCommit 0;
private _button = _display ctrlCreate ["RscButton", 1600];
	_button ctrlSetPosition [0.4, 0.82, 0.2, 0.05];
	_button ctrlSetText "Select";
	_button ctrlCommit 0;
private _factionPairs = [];
{
	if ((getNumber (_x >> "side")) in [0, 2]) then 
	{
		private _class = configName _x;
		private _dispName = getText (_x >> "displayName");
		_factionPairs pushBack [_dispName, _class];
	};
} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
{
	private _index = _listbox lbAdd (_x select 0);
	private _factionClass = _x select 1;
	private _side = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
	private _color = [1,1,1,1];
	if (_side == 0) then { _color = [1,0,0,1] };
	if (_side == 2) then { _color = [0,1,0,1] };
	_listbox lbSetColor [_index, _color];
} forEach _factionPairs;
_listbox lbSetCurSel 0;
private _countLabel = _display ctrlCreate ["RscText", 1002];
	_countLabel ctrlSetText "Number of objectives:";
	_countLabel ctrlSetPosition [0.31, 0.62, 0.38, 0.05];
	_countLabel ctrlSetBackgroundColor [0,0,0,0];
	_countLabel ctrlSetTextColor [1,1,1,1];
	_countLabel ctrlCommit 0;
private _combo = _display ctrlCreate ["RscCombo", 1550];
	_combo ctrlSetPosition [0.32, 0.67, 0.36, 0.035];
	_combo ctrlCommit 0;
	_combo lbAdd "Random";
	for "_i" from 1 to 10 do 
	{
		_combo lbAdd str _i;
	};
	_combo lbSetCurSel 0;
private _nmeLabel = _display ctrlCreate ["RscText", 1003];
	_nmeLabel ctrlSetText "Enemy density:";
	_nmeLabel ctrlSetPosition [0.31, 0.72, 0.38, 0.05];
	_nmeLabel ctrlSetBackgroundColor [0,0,0,0];
	_nmeLabel ctrlSetTextColor [1,1,1,1];
	_nmeLabel ctrlCommit 0;
private _nmecombo = _display ctrlCreate ["RscCombo", 1551];
	_nmecombo ctrlSetPosition [0.32, 0.77, 0.36, 0.035];
	_nmecombo ctrlCommit 0;
	_nmecombo lbAdd "Random";
	_nmecombo lbAdd "Low";
	_nmecombo lbAdd "Medium";
	_nmecombo lbAdd "High";
	_nmecombo lbAdd "Maximum";
	_nmecombo lbSetCurSel 0;
private _factionPairsCopy = +_factionPairs;
_button ctrlAddEventHandler ["ButtonClick", 
{
	params ["_ctrl"];
	private _disp = ctrlParent _ctrl;
	private _list = _disp displayCtrl 1500;
	private _selectedIndex = lbCurSel _list;
	private _selectedDisplayName = _list lbText _selectedIndex;
	private _factionClass = call
	{
		{
			private _displayName = getText (_x >> "displayName");
			if (_displayName == _selectedDisplayName) exitWith 
			{
				configName _x;
			};
		} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
	};
	private _comboCtrl = _disp displayCtrl 1550;
	private _comboSel = lbCurSel _comboCtrl;
	private _objCount = 3;
	if (_comboSel == 0) then 
	{
		_objCount = floor random 8 + 2;
	} 
	else 
	{
		_objCount = _comboSel;
	};
	private _nmecomboCtrl = _disp displayCtrl 1551;
	private _nmecomboSel = lbCurSel _nmecomboCtrl;
	private _enemyDensity = 3;
	if (_nmecomboSel == 0) then 
	{
		_enemyDensity = 0;
	} else {
		_enemyDensity = _nmecomboSel;
	};
	[_selectedDisplayName,_factionClass,_objCount,_enemyDensity] remoteExecCall ["bro_fnc_automission_make", 2];
	systemChat format ["Selected Faction: %1 (%2), ObjCount: %3, EnemyDensity: %4", _selectedDisplayName, _factionClass, _objCount,_enemyDensity];
	_disp closeDisplay 1;
}];
deleteVehicle _logic;