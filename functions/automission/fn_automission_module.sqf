bro_fnc_automission_make = {
	params ["_selectedDisplayName","_factionClass","_objCount"];
	// STEP 2. SEND TO SERVER AND DO SHIT
	private _sideIndex = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
	private _factionSide = [east, west, independent, civilian] select _sideIndex;
	if (([_factionSide, west] call BIS_fnc_sideIsEnemy) == false) then {
		_factionSide setFriend [west, 0];
		west setFriend [_factionSide, 0];
		systemChat format ["%1 is the selected faction, and is now hostile to BLUFOR.", _selectedDisplayName];
	};
	{deleteMarkerLocal _x} forEach allMapMarkers;
// GET ALL INFANTRY IN FACTION:
	enemyInfantry = [];
	{
		if (
			getText (_x >> "faction") == _factionClass && {getNumber (_x >> "isMan") == 1} && {getNumber (_x >> "scope") == 2}
		) then {
			enemyInfantry pushBack (configName _x);
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));
// GET ALL VICS IN FACTION:
	private _allConfigs = configFile >> "CfgVehicles";
	allVics = [];
	{
		private _cfg = _x;
		private _isMan = getNumber (_cfg >> "isMan") == 0;
		private _isCar = getText (_cfg >> "vehicleClass") == "Car";
		private _isPublic = getNumber (_cfg >> "scope") == 2;
		if (_isMan && _isCar && (getText (_cfg >> "faction") == _factionClass) && _isPublic) then {
			allVics pushBack (configName _cfg);
		};
	} forEach ("true" configClasses _allConfigs);
	armedVics = [];
	{
		private _cfg = _x;
		private _isMan = getNumber (_cfg >> "isMan") == 0;
		private _isCar = getText (_cfg >> "vehicleClass") == "Car";
		private _isPublic = getNumber (_cfg >> "scope") == 2;
		if (_isMan && _isCar && (getText (_cfg >> "faction") == _factionClass) && _isPublic) then {
			private _hasWeapons = false;
			private _turrets = _cfg >> "Turrets";
			for "_i" from 0 to (count _turrets - 1) do {
				private _turret = _turrets select _i;
				private _weapons = getArray (_turret >> "weapons");
				if (count _weapons > 0) exitWith { _hasWeapons = true };
			};
			if (_hasWeapons) then {
				armedVics pushBack (configName _cfg);
			};
		};
	} forEach ("true" configClasses _allConfigs);
// MAKE REST OF OBJECTIVE:
	if (!isNil "ObjectiveCaches") then
	{
		systemChat format ["Removing: %1 units, %2 caches, %3 vehicles.",count SpawnedEnemyMasterList,count ObjectiveCaches,count ObjectiveVehicles];	// DEBUG LINE
		{deleteVehicle _x} forEach ObjectiveCaches+SpawnedEnemyMasterList+ObjectiveVehicles;
		{
			deleteVehicleCrew _x;
		} forEach ObjectiveVehicles;
	};
	{deleteVehicle _x} forEach AllDeadMen;
	// Minimum number of garrisonable positions in a building to be eligible:
	garrCount = 2;
	// If BuildingMasterList is nil (which it is in this case), then create the list:
	if (isNil "BuildingMasterList") then
	{
	// Make master list of all buildings on map:
		BuildingMasterList = nearestObjects [[(worldSize/2),(worldSize/2)],["HOUSE"],(worldSize / 2),true];
	// If a building has <= X number of garrison positions defined in garrCount, add it to this array to get deleted from the master list later:
		private _buildingsToDelete = [];
	// Iterate through each building- if no other eligible buildings within 150m, add to removal list:
		{
			if (count (_x buildingPos -1) <= garrCount) then 
			{
				_buildingsToDelete pushBack _x;
			};
		} forEach BuildingMasterList;
	// Find and remove each ineligible building from the master list:
		{
			private _deleteBuilding = BuildingMasterList find _x;
			BuildingMasterList deleteAt _deleteBuilding;
		} forEach _buildingsToDelete;
	// Iterate through remaining buildings and if more than 150m away from nearest building, remove it:
		_buildingsToDelete = [];
		{
			private _b = _x;
			// All other buildings (excluding this one)
			private _others = BuildingMasterList - [_b];
			// Find nearby buildings from the others
			private _nearOthers = _others select {_b distance _x <= 150};
			// If no nearby buildings found, mark for deletion
			if (count _nearOthers < 3) then
			{
				_buildingsToDelete pushBack _b;
			};
		} forEach BuildingMasterList;
	// Remove them from the master list too:
		{
			private _deleteBuilding = BuildingMasterList find _x;
			BuildingMasterList deleteAt _deleteBuilding;
		} forEach _buildingsToDelete;
		systemChat format ["%1 eligible objective buildings detected.",count BuildingMasterList];
	};
	// Develop objCount number of objectives across map:
	Objectives = [];
	ObjectiveCaches = [];
	ObjectiveVehicles = [];
	for "_i" from 1 to _objCount do
	{
		Objectives pushbackUnique (selectRandom BuildingMasterList);
	};
	// CREATE OBJECTIVES!!!:
	SpawnedEnemyMasterList = [];
	{
		_enemyGroup = nil;
		_enemyGroup2 = nil;
		_enemyGroup3 = nil;
		_enemyGroup4 = nil;
		private _enemyGroup = createGroup _factionSide;
		private _enemyGroup2 = createGroup _factionSide;
		private _enemyGroup3 = createGroup _factionSide;
		private _enemyGroup4 = createGroup _factionSide;
		_masterIndex = _forEachIndex + 1;
		// Decide how many buildings to populate (3–7 per objective):
		private _numObjectives = floor random 4 + 3;
		_selBldg = _x;
		// Sort BuildingMasterList by distance to first building:
		private _sortedBuildings = BuildingMasterList apply { [_x, _x distance2D _selBldg] };
		_sortedBuildings sort true;
		// Extract closest _numObjectives buildings
		_selectedObjBuildings = (_sortedBuildings select [0, _numObjectives]) apply { _x select 0 };
		// Offset coords for patrol spawns:
		_patrolSpawn = [(getPos _x select 0) + 20,(getPos _x select 1) + 20];
	// GRG MARKERS:
		{
			_tempMarker1 = createMarkerLocal [str _x,position _x];
			_tempMarker1 setMarkerType "Contact_dot1";
			_tempMarkerIndex = format ["%1%2%3",_masterIndex,0,_forEachIndex+1];
			_tempMarker1 setMarkerText _tempMarkerIndex;
		} forEach _selectedObjBuildings + [_x];
	// SPAWN UNITS IN SELECTED OBJ BUILDINGS:
		{
			numPos = _x buildingPos -1;
			for [{_i = 1},{_i<=(count numPos - 1)},{_i=_i+(floor random 2+1)}] do
			{
				_nextpos = numPos deleteAt floor random (count numPos);
				_unitType = selectRandom enemyInfantry;
				_enemySpawned = _enemyGroup createUnit [_unitType,_nextpos,[],0,"CAN_COLLIDE"];
				_enemySpawned setSkill ["spotTime", 0.5];_enemySpawned setSkill ["aimingAccuracy", 0.01];_enemySpawned setSkill ["aimingShake", 0.5];_enemySpawned setSkill ["aimingSpeed", 0.3];_enemySpawned setSkill ["spotDistance", 0.5];_enemySpawned setSkill ["courage", 1.0];_enemySpawned setSkill ["commanding", 1.0];_enemySpawned setSkill ["general", 0.15];_enemySpawned disableAI "PATH";_enemySpawned setBehaviour "SAFE";_enemySpawned setunitpos "UP";
				SpawnedEnemyMasterList pushBack _enemySpawned;
			};
		} forEach _selectedObjBuildings + [_x];
	// SPAWN CACHES, ONE PER OBJ:
			_objCacheAttacher = "Land_HelipadEmpty_F" createVehicle (selectRandom (selectRandom (_selectedObjBuildings + [_x]) buildingPos -1));
			_objCache = (selectRandom ["Box_Syndicate_Ammo_F","Box_Syndicate_Wps_F","Box_Syndicate_WpsLaunch_F"]) createVehicle [0,0,100];
			_objCache attachTo [_objCacheAttacher,[0,0,2]];
			detach _objCache;
			deleteVehicle _objCacheAttacher;
			ObjectiveCaches pushBack _objCache;
	// SPAWN TWO EXTERNAL PATROLS PER OBJECTIVE:
		for "_i" from 1 to (floor random 4+2) do
		{
			_enemySpawned = _enemyGroup2 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
			_enemySpawned setSkill ["spotTime", 0.5];_enemySpawned setSkill ["aimingAccuracy", 0.1];_enemySpawned setSkill ["aimingShake", 0.1];_enemySpawned setSkill ["aimingSpeed", 0.3];_enemySpawned setSkill ["spotDistance", 0.5];_enemySpawned setSkill ["courage", 1.0];_enemySpawned setSkill ["commanding", 1.0];_enemySpawned setSkill ["general", 0.25];_enemySpawned setBehaviour "SAFE";_enemySpawned setunitpos "UP";
			SpawnedEnemyMasterList pushBack _enemySpawned;
		};
		[_enemyGroup2, (getPosATL _x), (floor random 25+20)] call bis_fnc_taskPatrol;
		for "_i" from 1 to (floor random 4+2) do
		{
			_enemySpawned = _enemyGroup3 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
			_enemySpawned setSkill ["spotTime", 0.5];_enemySpawned setSkill ["aimingAccuracy", 0.1];_enemySpawned setSkill ["aimingShake", 0.1];_enemySpawned setSkill ["aimingSpeed", 0.3];_enemySpawned setSkill ["spotDistance", 0.5];_enemySpawned setSkill ["courage", 1.0];_enemySpawned setSkill ["commanding", 1.0];_enemySpawned setSkill ["general", 0.25];_enemySpawned setBehaviour "SAFE";_enemySpawned setunitpos "UP";
			SpawnedEnemyMasterList pushBack _enemySpawned;
		};
		[_enemyGroup3, (getPosATL _x), (floor random 80+60)] call bis_fnc_taskPatrol;
	// SPAWN VEHICLES ON ROADS NEARBY:
	if (count armedVics != 0 && count allVics != 0) then {
		_nearbyRoadList = nearestTerrainObjects [(selectRandom _selectedObjBuildings), ["ROAD", "MAIN ROAD", "TRACK","TRAIL"], 350];
			_nearbyRoad = _nearbyRoadList select 0;
			_nearbyRoad2 = _nearbyRoadList select 3;
			_nearbyRoad3 = _nearbyRoadList select 5;
			// Spawn 2 empty vics on the road nearby, and 1 with a 25% chance to have enemies in it
			switch ([1,2] selectRandomWeighted [0.75,0.25]) do
			{
				case 1: {
					_result = [getPosATL _nearbyRoad,0,selectRandom armedVics, _enemyGroup4] call BIS_fnc_spawnVehicle;
					objVic = _result select 0;
					SpawnedEnemyMasterList append (_result select 1);
				};
				case 2: {
					objVic = createVehicle [selectRandom armedVics,_nearbyRoad];
				};
			};
			objVic setDir ((objVic getDir _nearbyRoad2)-180);
			objVic2 = createVehicle [selectRandom allVics,_nearbyRoad2];
			objVic2 setDir (objVic2 getDir _nearbyRoad);
			objVic3 = createVehicle [selectRandom allVics,_nearbyRoad3];
			objVic3 setDir (objVic3 getDir _nearbyRoad2);
			{
				ObjectiveVehicles pushback _x;
			} forEach [objVic,objVic2,objVic3];
		};
	} forEach Objectives;
	// DEBUG LINES: Output
	if (count armedVics == 0 && count allVics == 0) then {
		systemChat format ["%1 has no eligible vehicles to spawn.",_selectedDisplayName];
	};
	systemChat format ["%1 new objectives created.",count Objectives];
};
bro_fnc_automission_select = {
	systemChat "Notice from Automission: When you spawn the objective(s), your game will lag for a bit. This only happens the first time this is used per session as the function needs to index all eligible buildings to spawn objectives on. You'll be alright, just give it a few moments.";
	disableSerialization;
	// Create a simple display
	private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
	// Background
	private _background = _display ctrlCreate ["RscText", 1000];
	_background ctrlSetPosition [0.3, 0.2, 0.4, 0.5];
	_background ctrlSetBackgroundColor [0,0,0,0.7];
	_background ctrlCommit 0;
	// Listbox
	private _listbox = _display ctrlCreate ["RscListbox", 1500];
	_listbox ctrlSetPosition [0.32, 0.25, 0.36, 0.35];
	_listbox ctrlCommit 0;
	// Button
	private _button = _display ctrlCreate ["RscButton", 1600];
	_button ctrlSetPosition [0.4, 0.62, 0.2, 0.05];
	_button ctrlSetText "Select";
	_button ctrlCommit 0;
	// Get OPFOR and INDFOR factions
	private _factionPairs = []; // [displayName, className]
	{
		if ((getNumber (_x >> "side")) in [0, 2]) then {
			private _class = configName _x;
			private _dispName = getText (_x >> "displayName");
			_factionPairs pushBack [_dispName, _class];
		};
	} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
	// Populate listbox with display names
	{
		private _index = _listbox lbAdd (_x select 0);
		private _factionClass = _x select 1;
		private _side = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
		private _color = [1,1,1,1]; // default white
		if (_side == 0) then { _color = [1,0,0,1] };     // red for OPFOR
		if (_side == 2) then { _color = [0,1,0,1] };     // green for INDFOR
		_listbox lbSetColor [_index, _color];
	} forEach _factionPairs;
// TEST OBJ COUNT SELECTOR:
// Combo box to select objective count (Random, 1–10)
private _combo = _display ctrlCreate ["RscCombo", 1550];
_combo ctrlSetPosition [0.32, 0.61, 0.36, 0.035];
_combo ctrlCommit 0;
// Populate combo with options
_combo lbAdd "Random";
for "_i" from 1 to 10 do {
	_combo lbAdd str _i;
};
_combo lbSetCurSel 0; // Default to Random

	// --- Closure to capture _factionPairs ---
	private _factionPairsCopy = +_factionPairs;
	_button ctrlAddEventHandler ["ButtonClick", {
		disableSerialization;
		params ["_ctrl"];
		private _disp = ctrlParent _ctrl;
		private _list = _disp displayCtrl 1500;
		private _selectedIndex = lbCurSel _list;
		private _selectedDisplayName = _list lbText _selectedIndex;
		_disp closeDisplay 1;
		private _factionClass = "";
		{
			private _displayName = getText (_x >> "displayName");
			if (_displayName == _selectedDisplayName) exitWith {
				_factionClass = configName _x;
			};
		} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
// TEST: Obj Count selector
private _comboCtrl = _disp displayCtrl 1550;
private _comboSel = lbCurSel _comboCtrl;
if (_comboSel == 0) then {
	_objCount = floor random 6 + 2; // Default random behavior
} else {
	_objCount = _comboSel; // 1–10 (index matches value)
};
		
		[_selectedDisplayName,_factionClass,_objCount] remoteExecCall ["bro_fnc_automission_make", 2];
		systemChat format ["Selected Faction: %1 (%2)", _selectedDisplayName, _factionClass];	// DEBUG LINE
	}]
};
call bro_fnc_automission_select;