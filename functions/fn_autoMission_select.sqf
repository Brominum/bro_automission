if (typeOf (_this select 0) == "Bro_Automission_Module") then {deleteVehicle (_this select 0)};
disableSerialization;
private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
private _background = _display ctrlCreate ["RscText", 1000];
	_background ctrlSetPosition [0.25, 0.1, 0.5, 0.85]; // Made taller and wider
	_background ctrlSetBackgroundColor [0,0,0,0.7];
	_background ctrlCommit 0;

// --- FACTION ---
private _factionLabel = _display ctrlCreate ["RscText", 1001];
	_factionLabel ctrlSetText "Faction to spawn:";
	_factionLabel ctrlSetPosition [0.26, 0.11, 0.38, 0.05];
	_factionLabel ctrlSetBackgroundColor [0,0,0,0];
	_factionLabel ctrlSetTextColor [1,1,1,1];
	_factionLabel ctrlCommit 0;
private _listbox = _display ctrlCreate ["RscListbox", 1500];
	_listbox ctrlSetPosition [0.27, 0.16, 0.46, 0.25]; // Adjusted size
	_listbox ctrlCommit 0;

// --- SELECT BUTTON ---
private _button = _display ctrlCreate ["RscButton", 1600];
	_button ctrlSetPosition [0.4, 0.88, 0.2, 0.05];
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

// Load Saved Faction
private _lastFaction = profileNamespace getVariable ["bro_missionGen_lastFaction", ""];
private _selIndex = 0;
if (_lastFaction != "") then {
	{
		if ((_x select 1) == _lastFaction) exitWith { _selIndex = _forEachIndex; };
	} forEach _factionPairs;
};
_listbox lbSetCurSel _selIndex;

// --- OBJECTIVE COUNT ---
private _countLabel = _display ctrlCreate ["RscText", 1002];
	_countLabel ctrlSetText "Number of objectives:";
	_countLabel ctrlSetPosition [0.26, 0.42, 0.2, 0.04];
	_countLabel ctrlCommit 0;
private _combo = _display ctrlCreate ["RscCombo", 1550];
	_combo ctrlSetPosition [0.27, 0.46, 0.2, 0.035];
	_combo ctrlCommit 0;
	_combo lbAdd "Random";
	for "_i" from 1 to 10 do { _combo lbAdd str _i; };
_combo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastObjCount", 0]);

// --- ENEMY DENSITY ---
private _nmeLabel = _display ctrlCreate ["RscText", 1003];
	_nmeLabel ctrlSetText "Enemy density:";
	_nmeLabel ctrlSetPosition [0.51, 0.42, 0.2, 0.04];
	_nmeLabel ctrlCommit 0;
private _nmecombo = _display ctrlCreate ["RscCombo", 1551];
	_nmecombo ctrlSetPosition [0.52, 0.46, 0.2, 0.035];
	_nmecombo ctrlCommit 0;
	_nmecombo lbAdd "Random";
	_nmecombo lbAdd "Low";
	_nmecombo lbAdd "Medium";
	_nmecombo lbAdd "High";
	_nmecombo lbAdd "Maximum";
_nmecombo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastDensity", 0]);

// --- MISSION TYPE ---
private _typeLabel = _display ctrlCreate ["RscText", 1004];
	_typeLabel ctrlSetText "Mission Type:";
	_typeLabel ctrlSetPosition [0.26, 0.51, 0.2, 0.04];
	_typeLabel ctrlCommit 0;
private _typeCombo = _display ctrlCreate ["RscCombo", 1552];
	_typeCombo ctrlSetPosition [0.27, 0.55, 0.2, 0.035];
	_typeCombo ctrlCommit 0;
	_typeCombo lbAdd "Random (Mixed)";
	_typeCombo lbAdd "Destroy Caches";
	_typeCombo lbAdd "Hostage Rescue";
_typeCombo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastType", 0]);

// --- LOCATION CONTEXT ---
private _locLabel = _display ctrlCreate ["RscText", 1005];
	_locLabel ctrlSetText "Location Context:";
	_locLabel ctrlSetPosition [0.51, 0.51, 0.2, 0.04];
	_locLabel ctrlCommit 0;
private _locCombo = _display ctrlCreate ["RscCombo", 1553];
	_locCombo ctrlSetPosition [0.52, 0.55, 0.2, 0.035];
	_locCombo ctrlCommit 0;
	_locCombo lbAdd "Random / Mixed";
	_locCombo lbAdd "Urban (City)";
	_locCombo lbAdd "Rural (Isolated)";
_locCombo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastLoc", 0]);

// --- ENEMY POSTURE ---
private _postureLabel = _display ctrlCreate ["RscText", 1006];
	_postureLabel ctrlSetText "Enemy Posture:";
	_postureLabel ctrlSetPosition [0.26, 0.60, 0.2, 0.04];
	_postureLabel ctrlCommit 0;
private _postureCombo = _display ctrlCreate ["RscCombo", 1554];
	_postureCombo ctrlSetPosition [0.27, 0.64, 0.2, 0.035];
	_postureCombo ctrlCommit 0;
	_postureCombo lbAdd "Random";
	_postureCombo lbAdd "Standard Infantry";
	_postureCombo lbAdd "Mechanized (Armor)";
_postureCombo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastPosture", 0]);

// --- CIVILIAN PRESENCE ---
private _civLabel = _display ctrlCreate ["RscText", 1007];
	_civLabel ctrlSetText "Civilian Presence:";
	_civLabel ctrlSetPosition [0.51, 0.60, 0.2, 0.04];
	_civLabel ctrlCommit 0;
private _civCombo = _display ctrlCreate ["RscCombo", 1555];
	_civCombo ctrlSetPosition [0.52, 0.64, 0.2, 0.035];
	_civCombo ctrlCommit 0;
	_civCombo lbAdd "Random";
	_civCombo lbAdd "None";
	_civCombo lbAdd "Low";
	_civCombo lbAdd "High";
_civCombo lbSetCurSel (profileNamespace getVariable ["bro_missionGen_lastCiv", 0]);

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
	
	// Obj Count
	private _comboSel = lbCurSel (_disp displayCtrl 1550);
	private _objCount = 3;
	if (_comboSel == 0) then { _objCount = floor random 8 + 2; } else { _objCount = _comboSel; };
	
	// Density
	private _nmecomboSel = lbCurSel (_disp displayCtrl 1551);
	private _enemyDensity = 3;
	if (_nmecomboSel == 0) then { _enemyDensity = 0; } else { _enemyDensity = _nmecomboSel; };
	
	// Type
	private _missionTypeIndex = lbCurSel (_disp displayCtrl 1552);
	
	// Location
	private _locIndex = lbCurSel (_disp displayCtrl 1553);
	
	// Posture
	private _postureIndex = lbCurSel (_disp displayCtrl 1554);
	
	// Civs
	private _civIndex = lbCurSel (_disp displayCtrl 1555);
	
	// SAVE SELECTIONS
	profileNamespace setVariable ["bro_missionGen_lastFaction", _factionClass];
	profileNamespace setVariable ["bro_missionGen_lastObjCount", _comboSel];
	profileNamespace setVariable ["bro_missionGen_lastDensity", _nmecomboSel];
	profileNamespace setVariable ["bro_missionGen_lastType", _missionTypeIndex];
	profileNamespace setVariable ["bro_missionGen_lastLoc", _locIndex];
	profileNamespace setVariable ["bro_missionGen_lastPosture", _postureIndex];
	profileNamespace setVariable ["bro_missionGen_lastCiv", _civIndex];
	saveProfileNamespace;

	[_selectedDisplayName,_factionClass,_objCount,_enemyDensity, _missionTypeIndex, _locIndex, _postureIndex, _civIndex] remoteExecCall ["bro_fnc_automission_make", 2];
	systemChat format ["Selected Faction: %1, Obj: %2, Den: %3, Type: %4, Loc: %5, Pos: %6, Civ: %7", _selectedDisplayName, _objCount, _enemyDensity, _missionTypeIndex, _locIndex, _postureIndex, _civIndex];
	_disp closeDisplay 1;
}];