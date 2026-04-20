params ["_selectedDisplayName","_factionClass","_objCount","_enemyDensity", ["_missionTypeIndex", 0], ["_locIndex", 0], ["_postureIndex", 0], ["_civIndex", 0]];

if (isNil "_selectedDisplayName" || isNil "_factionClass" || isNil "_objCount" || isNil "_enemyDensity") exitWith {
	systemChat "ERROR: Missing required parameters for mission generation.";
};

// --- DENSITY LOGIC ---
switch (_enemyDensity) do {
	case 0: {_enemyDensity = floor random 4+2};
	case 1: {_enemyDensity = 6};
	case 2: {_enemyDensity = 4};
	case 3: {_enemyDensity = 2};
	case 4: {_enemyDensity = 1};
	default {_enemyDensity = floor random 4+2};
};

// --- FACTION LOGIC ---
private _sideIndex = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
if (_sideIndex == -1) exitWith {
	systemChat format ["ERROR: Invalid faction class '%1'. Mission generation aborted.",_factionClass];
};
private _factionSide = [east, west, independent, civilian] select _sideIndex;
if (([_factionSide, west] call BIS_fnc_sideIsEnemy) == false) then {
	_factionSide setFriend [west, 0];
	west setFriend [_factionSide, 0];
};

// --- CLEANUP ---
{deleteMarker _x} forEach allMapMarkers;
if (!isNil "ObjectiveCaches") then {
	systemChat format ["Removed: %1 units, %2 caches, %3 vehicles.",count SpawnedEnemyMasterList,count ObjectiveCaches,count ObjectiveVehicles];
	{deleteVehicle _x} forEach (ObjectiveCaches + SpawnedEnemyMasterList + ObjectiveVehicles);
	{deleteVehicleCrew _x} forEach ObjectiveVehicles;
};
if (!isNil "allReinforcements") then {
	systemChat format ["Removed: %1 reinforcements.",count allReinforcements];
	{deleteVehicle _x} forEach allReinforcements;
};
if (!isNil "AllDeadMen") then {
	{deleteVehicle _x} forEach AllDeadMen;
};

// --- ASSET LISTS ---
enemyInfantry = [];
allVics = [];
armedVics = [];
private _cacheTypes = ["Box_Syndicate_Ammo_F","Box_Syndicate_Wps_F","Box_Syndicate_WpsLaunch_F"];
private _allConfigs = "true" configClasses (configFile >> "CfgVehicles");
{
	private _faction = getText (_x >> "faction");
	if (_faction == _factionClass && {getNumber (_x >> "scope") == 2}) then {
		if (getNumber (_x >> "isMan") == 1) then {
			enemyInfantry pushBack (configName _x);
		} else {
			if (getNumber (_x >> "numberPhysicalWheels") >= 1 && {getNumber (_x >> "type") != 2} && {getNumber (_x >> "isUav") != 1} && {getText (_x >> "simulation") != "tankx"}) then {
				allVics pushBack (configName _x);
			};
		};
	};
} forEach _allConfigs;

if (count enemyInfantry == 0) exitWith {
	systemChat format ["ERROR: Faction '%1' has no infantry units available. Mission generation aborted.",_selectedDisplayName];
};
{
	if (str ([_x,array] call BIS_fnc_getTurrets) find "MainTurret" != -1) then {
		armedVics pushback _x;
	};
} forEach allVics;

// --- BUILDING FINDER & LOCATION FILTERING ---
private _BuildingMasterList = [] call bro_fnc_buildingFinder;

// 0=Random(Mixed), 1=Urban, 2=Rural
if (_locIndex == 1) then {
	// URBAN: Keep buildings with > 5 neighbors within 75m
	private _urbanList = _BuildingMasterList select { count (nearestObjects [_x, ["HOUSE"], 75]) >= 6 };
	if (count _urbanList > 0) then {
		_BuildingMasterList = _urbanList;
		systemChat format ["Location Filter: Urban selected (%1 candidates)", count _BuildingMasterList];
	} else {
		systemChat "Location Filter: Urban selected but no suitable areas found. Reverting to mixed.";
	};
};
if (_locIndex == 2) then {
	// RURAL: Keep buildings with < 3 neighbors within 100m
	private _ruralList = _BuildingMasterList select { count (nearestObjects [_x, ["HOUSE"], 100]) <= 3 };
	if (count _ruralList > 0) then {
		_BuildingMasterList = _ruralList;
		systemChat format ["Location Filter: Rural selected (%1 candidates)", count _BuildingMasterList];
	} else {
		systemChat "Location Filter: Rural selected but no suitable areas found. Reverting to mixed.";
	};
};

if (count _BuildingMasterList < _objCount) then {
	systemChat format ["WARNING: Only %1 suitable buildings found, reducing objectives from %2 to %3.",count _BuildingMasterList,_objCount,count _BuildingMasterList];
	_objCount = count _BuildingMasterList;
};
if (_objCount < 1) exitWith {
	systemChat "ERROR: No suitable buildings found for objectives. Mission generation aborted.";
};

// --- OBJECTIVE SELECTION ---
Objectives = [];
ObjectiveCaches = [];
ObjectiveVehicles = [];
SpawnedEnemyMasterList = [];
for "_i" from 1 to _objCount do {
	Objectives pushbackUnique (selectRandom _BuildingMasterList);
};

private _failedObjectives = 0;

{
	private _enemyGroup = createGroup _factionSide;
	private _enemyGroup2 = createGroup _factionSide;
	private _enemyGroup3 = createGroup _factionSide;
	private _enemyGroup4 = createGroup _factionSide;
	private _masterIndex = _forEachIndex + 1;
	private _numObjectives = floor random 4 + 3;
	private _selBldg = _x;
	
	if (isNull _selBldg) then { _failedObjectives = _failedObjectives + 1; continue; };
	
	private _sortedBuildings = _BuildingMasterList apply {[_x, _x distance2D _selBldg]};
	_sortedBuildings sort true;
	private _selectedObjBuildings = (_sortedBuildings select [0, _numObjectives min (count _sortedBuildings)]) apply {_x select 0};
	private _objPos = getPos _x;
	if (count _objPos < 2) then { _failedObjectives = _failedObjectives + 1; continue; };
	private _patrolSpawn = [(_objPos select 0) + 20,(_objPos select 1) + 20];
	
	// Create Markers
	{
		private _tempMarker1 = createMarker [str _x,position _x];
		_tempMarker1 setMarkerType "Contact_dot1";
		private _tempMarkerIndex = format ["%1%2%3",_masterIndex,0,_forEachIndex+1];
		_tempMarker1 setMarkerText _tempMarkerIndex;
	} forEach (_selectedObjBuildings + [_x]);
	
	// SPAWN DEFENDERS
	private _validBuildingPos = [];
	private _spawnedInBuildings = 0;
	{
		private _numPos = _x buildingPos -1;
		if (count _numPos > 0) then {
			for [{private _i = 1},{_i <= (count _numPos - 1)},{_i = _i + _enemyDensity}] do {
				private _nextpos = _numPos deleteAt floor random (count _numPos);
				private _unitType = selectRandom enemyInfantry;
				private _enemySpawned = _enemyGroup createUnit [_unitType,_nextpos,[],0,"CAN_COLLIDE"];
				if (!isNull _enemySpawned) then {
					[_enemySpawned,true] call bro_fnc_setSkills;
					SpawnedEnemyMasterList pushBack _enemySpawned;
					_spawnedInBuildings = _spawnedInBuildings + 1;
				};
			};
			_validBuildingPos append _numPos;
		};
	} forEach (_selectedObjBuildings + [_x]);

	// --- DETERMINE OBJECTIVE TYPE ---
	private _thisObjType = _missionTypeIndex;
	if (_missionTypeIndex == 0) then { _thisObjType = selectRandom [1, 2]; };
	
	// --- HOSTAGE LOGIC ---
	if (_thisObjType == 2) then {
		if (count _validBuildingPos > 0) then {
			private _hostageCount = floor random 3 + 1;
			for "_h" from 1 to _hostageCount do {
				if (count _validBuildingPos == 0) exitWith {};
				private _hPos = _validBuildingPos deleteAt (floor random (count _validBuildingPos));
				private _grpCiv = createGroup civilian;
				private _civType = selectRandom ["C_Man_casual_1_F","C_man_p_beggar_F","C_man_polo_1_F"];
				private _hostage = _grpCiv createUnit [_civType, _hPos, [], 0, "CAN_COLLIDE"];
				removeGoggles _hostage;
				_hostage addGoggles "G_Blindfold_01_black_F";
				_hostage setCaptive true;
				_hostage setDir (random 360);
				_hostage disableAI "PATH"; 
				_hostage switchMove "Acts_AidlPsitMstpSsurWnonDnon_loop";
				[
					_hostage, "Free Hostage", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
					"_this distance _target < 2", "_caller distance _target < 2", {}, {},
					{
						params ["_target", "_caller", "_actionId", "_arguments"];
						_target switchMove ""; _target enableAI "ANIM"; _target disableAI "PATH";
						["Hostage Freed!", "PLAIN", 0.5] remoteExec ["titleText", _caller];
						removeAllActions _target;
					}, {}, [], 5, 0, true, false
				] remoteExec ["BIS_fnc_holdActionAdd", 0, _hostage];
				ObjectiveCaches pushBack _hostage;
			};
		};
	};

	// --- CACHE LOGIC ---
	if (_thisObjType == 1) then {
		if (count _validBuildingPos > 0) then {
			private _objCacheAttacher = "Land_HelipadEmpty_F" createVehicle (selectRandom _validBuildingPos);
			private _objCache = (selectRandom _cacheTypes) createVehicle [0,0,100];
			_objCache attachTo [_objCacheAttacher,[0,0,2]];
			detach _objCache;
			deleteVehicle _objCacheAttacher;
			ObjectiveCaches pushBack _objCache;
		} else {
			private _objCache = (selectRandom _cacheTypes) createVehicle _objPos;
			ObjectiveCaches pushBack _objCache;
		};
	};
	
	// --- CIVILIAN PRESENCE ---
	// 0=Random, 1=None, 2=Low, 3=High
	private _spawnCivs = false;
	private _civCount = 0;
	if (_civIndex == 0) then { if (random 1 > 0.5) then { _spawnCivs = true; _civCount = floor random 5 + 2; }; };
	if (_civIndex == 2) then { _spawnCivs = true; _civCount = floor random 3 + 2; };
	if (_civIndex == 3) then { _spawnCivs = true; _civCount = floor random 6 + 6; };
	
	if (_spawnCivs) then {
		private _grpAmbientCiv = createGroup civilian;
		for "_c" from 1 to _civCount do {
			private _civPos = [(_objPos select 0) + (random 40 - 20), (_objPos select 1) + (random 40 - 20)];
			private _civUnit = _grpAmbientCiv createUnit [selectRandom ["C_Man_casual_1_F","C_man_p_beggar_F","C_man_polo_1_F"], _civPos, [], 0, "NONE"];
			[_civUnit, _objPos, 50] call bis_fnc_taskPatrol;
			ObjectiveCaches pushBack _civUnit; // Reuse cleanup list
		};
	};
	
	// SPAWN EXTERIOR PATROLS
	for "_i" from 1 to (floor random 4+2) do {
		private _enemySpawned = _enemyGroup2 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
		if (!isNull _enemySpawned) then {
			[_enemySpawned,false] call bro_fnc_setSkills;
			SpawnedEnemyMasterList pushBack _enemySpawned;
		};
	};
	if (count units _enemyGroup2 > 0) then { [_enemyGroup2, (getPosATL _x), (floor random 25+20)] call bis_fnc_taskPatrol; };
	
	for "_i" from 1 to (floor random 4+2) do {
		private _enemySpawned = _enemyGroup3 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
		if (!isNull _enemySpawned) then {
			[_enemySpawned,false] call bro_fnc_setSkills;
			SpawnedEnemyMasterList pushBack _enemySpawned;
		};
	};
	if (count units _enemyGroup3 > 0) then { [_enemyGroup3, (getPosATL _x), (floor random 80+60)] call bis_fnc_taskPatrol; };
	
	// --- VEHICLE LOGIC (MECHANIZED CHECK) ---
	// Posture: 0=Random, 1=Standard, 2=Mechanized
	private _isMechanized = false;
	if (_postureIndex == 2) then { _isMechanized = true; };
	if (_postureIndex == 0 && {random 1 < 0.3}) then { _isMechanized = true; };
	
	if (count armedVics != 0 && {count allVics != 0}) then {
		private _nearbyRoadList = nearestTerrainObjects [(selectRandom _selectedObjBuildings), ["ROAD", "MAIN ROAD", "TRACK","TRAIL"], 350];
		if (count _nearbyRoadList >= 6) then {
			private _nearbyRoad = _nearbyRoadList select 0;
			private _nearbyRoad2 = _nearbyRoadList select 3;
			private _nearbyRoad3 = _nearbyRoadList select 5;
			
			if (_isMechanized) then {
				// MECHANIZED: Force 2 Armed Vehicles
				// Vic 1: Guard/Static
				private _result1 = [getPosATL _nearbyRoad, 0, selectRandom armedVics, _enemyGroup4] call BIS_fnc_spawnVehicle;
				private _vic1 = _result1 select 0;
				SpawnedEnemyMasterList append (_result1 select 1);
				_vic1 setDir ((_vic1 getDir _nearbyRoad2)-180);
				ObjectiveVehicles pushBack _vic1;
				
				// Vic 2: Patrol
				private _grpMechPatrol = createGroup _factionSide;
				private _result2 = [getPosATL _nearbyRoad2, 0, selectRandom armedVics, _grpMechPatrol] call BIS_fnc_spawnVehicle;
				private _vic2 = _result2 select 0;
				SpawnedEnemyMasterList append (_result2 select 1);
				ObjectiveVehicles pushBack _vic2;
				[_grpMechPatrol, _objPos, 400] call bis_fnc_taskPatrol;
				
				systemChat format ["Objective %1: Mechanized Posture Active (2 Armed Vics)", _masterIndex];
			} else {
				// STANDARD: Chance for vehicles
				private _objVic = objNull;
				switch ([1,2] selectRandomWeighted [0.75,0.25]) do {
					case 1: {
						private _result = [getPosATL _nearbyRoad,0,selectRandom armedVics, _enemyGroup4] call BIS_fnc_spawnVehicle;
						_objVic = _result select 0;
						SpawnedEnemyMasterList append (_result select 1);
					};
					case 2: {
						_objVic = createVehicle [selectRandom armedVics,_nearbyRoad];
					};
				};
				if (!isNull _objVic) then {
					_objVic setDir ((_objVic getDir _nearbyRoad2)-180);
					ObjectiveVehicles pushBack _objVic;
				};
				private _objVic2 = createVehicle [selectRandom allVics,_nearbyRoad2];
				if (!isNull _objVic2) then {
					_objVic2 setDir (_objVic2 getDir _nearbyRoad);
					ObjectiveVehicles pushBack _objVic2;
				};
				private _objVic3 = createVehicle [selectRandom allVics,_nearbyRoad3];
				if (!isNull _objVic3) then {
					_objVic3 setDir (_objVic3 getDir _nearbyRoad2);
					ObjectiveVehicles pushBack _objVic3;
				};
			};
		} else {
			systemChat format ["WARNING: Objective %1 insufficient nearby roads (%2 found), skipping vehicles.",_masterIndex,count _nearbyRoadList];
		};
	};
} forEach Objectives;

if (count armedVics == 0 && {count allVics == 0}) then {
	systemChat format ["WARNING: %1 has no eligible vehicles to spawn.",_selectedDisplayName];
};
if (_failedObjectives > 0) then {
	systemChat format ["WARNING: %1 objectives failed to generate properly.",_failedObjectives];
};
systemChat format ["SUCCESS: %1 objectives created with %2 enemies spawned.",count Objectives,count SpawnedEnemyMasterList];
if (!isNil "ObjectiveTriggers") then {
	systemChat format ["Removed: %1 reinf triggers.",count ObjectiveTriggers];
	{deleteVehicle _x} forEach ObjectiveTriggers;
};
private _facDetect = "";
switch (_factionSide) do {
	case east: {_facDetect = "EAST D"};
	case independent: {_facDetect = "GUER D"};
	default {_facDetect = "EAST D"};
};
ObjectiveTriggers = [];
allReinforcements = [];
{
	if (!isNull _x) then {
		private _ReinfTrg = createTrigger ["EmptyDetector",getPos _x];
		private _triggerString = format ["[%1,%2] remoteExec ['bro_fnc_reinforceObj', 2];",getPos _x,str _factionClass];
		_ReinfTrg setTriggerArea [150, 150, 0, true];
		_ReinfTrg setTriggerActivation ["WEST",_facDetect,false];
		_ReinfTrg setTriggerStatements ["this && west countSide thisList > 0 ",_triggerString,""];
		ObjectiveTriggers pushBack _ReinfTrg;
	};
} forEach Objectives;