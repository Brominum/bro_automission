params ["_selectedDisplayName","_factionClass","_objCount","_enemyDensity"];
switch (_enemyDensity) do {
	case 0: {_enemyDensity = floor random 4+2};
	case 1: {_enemyDensity = 6};
	case 2: {_enemyDensity = 4};
	case 3: {_enemyDensity = 2};
	case 4: {_enemyDensity = 1};
	default {_enemyDensity = floor random 4+2};
};
private _sideIndex = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
private _factionSide = [east, west, independent, civilian] select _sideIndex;
if (([_factionSide, west] call BIS_fnc_sideIsEnemy) == false) then 
{
	_factionSide setFriend [west, 0];
	west setFriend [_factionSide, 0];
};
{deleteMarkerLocal _x} forEach allMapMarkers;
enemyInfantry = [];
allVics = [];
armedVics = [];
private _allConfigs = "true" configClasses (configFile >> "CfgVehicles");
{
	private _faction   = getText (_x >> "faction");
	private _isMan	 = getNumber (_x >> "isMan") == 1;
	private _isPublic  = getNumber (_x >> "scope") == 2;
	// filter by faction + scope first
	if (_faction == _factionClass && _isPublic) then {
		if (_isMan) then {
			// infantry unit
			enemyInfantry pushBack (configName _x);
		} else {
			// non-man vehicles, checked by making sure it has 1 or more wheels, is not a UAV, is not a heli, and is not a tank:
			private _isCar = (getNumber (_x >> "numberPhysicalWheels") >= 1
				&& getNumber (_x >> "type") != 2
				&& getNumber (_x >> "isUav") != 1
				&& getText (_x >> "simulation") != "tankx"
			);
			if (_isCar) then {
				private _vehName = configName _x;
				allVics pushBack _vehName;
			};
		};
	};
} forEach _allConfigs;
{
	private _turretArray = [_x,array] call BIS_fnc_getTurrets;
	if (str _turretArray find "MainTurret" != -1) then {
		armedVics pushback _x;
	};
} forEach allVics;
if (!isNil "ObjectiveCaches") then
{
	systemChat format ["Removed: %1 units, %2 caches, %3 vehicles.",count SpawnedEnemyMasterList,count ObjectiveCaches,count ObjectiveVehicles];
	{deleteVehicle _x} forEach ObjectiveCaches+SpawnedEnemyMasterList+ObjectiveVehicles;
	{
		deleteVehicleCrew _x;
	} forEach ObjectiveVehicles;
};
if (!isNil "allReinforcements") then
{
	systemChat format ["Removed: %1 reinforcements.",count allReinforcements];
	{deleteVehicle _x} forEach allReinforcements;
};
{deleteVehicle _x} forEach AllDeadMen;
_BuildingMasterList = [] call bro_fnc_buildingFinder;
Objectives = [];
ObjectiveCaches = [];
ObjectiveVehicles = [];
for "_i" from 1 to _objCount do
{
	Objectives pushbackUnique (selectRandom _BuildingMasterList);
};
SpawnedEnemyMasterList = [];
{
	private _enemyGroup = createGroup _factionSide;
	private _enemyGroup2 = createGroup _factionSide;
	private _enemyGroup3 = createGroup _factionSide;
	private _enemyGroup4 = createGroup _factionSide;
	_masterIndex = _forEachIndex + 1;
	private _numObjectives = floor random 4 + 3;
	_selBldg = _x;
	private _sortedBuildings = _BuildingMasterList apply { [_x, _x distance2D _selBldg] };
	_sortedBuildings sort true;
	_selectedObjBuildings = (_sortedBuildings select [0, _numObjectives]) apply { _x select 0 };
	_patrolSpawn = [(getPos _x select 0) + 20,(getPos _x select 1) + 20];
	{
		_tempMarker1 = createMarkerLocal [str _x,position _x];
		_tempMarker1 setMarkerType "Contact_dot1";
		_tempMarkerIndex = format ["%1%2%3",_masterIndex,0,_forEachIndex+1];
		_tempMarker1 setMarkerText _tempMarkerIndex;
	} forEach _selectedObjBuildings + [_x];
	{
		numPos = _x buildingPos -1;
		for [{_i = 1},{_i<=(count numPos - 1)},{_i=_i+_enemyDensity}] do
		{
			_nextpos = numPos deleteAt floor random (count numPos);
			_unitType = selectRandom enemyInfantry;
			_enemySpawned = _enemyGroup createUnit [_unitType,_nextpos,[],0,"CAN_COLLIDE"];
			[_enemySpawned,true] call bro_fnc_setSkills;
			SpawnedEnemyMasterList pushBack _enemySpawned;
		};
	} forEach _selectedObjBuildings + [_x];
		_objCacheAttacher = "Land_HelipadEmpty_F" createVehicle (selectRandom (selectRandom (_selectedObjBuildings + [_x]) buildingPos -1));
		_objCache = (selectRandom ["Box_Syndicate_Ammo_F","Box_Syndicate_Wps_F","Box_Syndicate_WpsLaunch_F"]) createVehicle [0,0,100];
		_objCache attachTo [_objCacheAttacher,[0,0,2]];
		detach _objCache;
		deleteVehicle _objCacheAttacher;
		ObjectiveCaches pushBack _objCache;
	for "_i" from 1 to (floor random 4+2) do
	{
		_enemySpawned = _enemyGroup2 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
		[_enemySpawned,false] call bro_fnc_setSkills;
		SpawnedEnemyMasterList pushBack _enemySpawned;
	};
	[_enemyGroup2, (getPosATL _x), (floor random 25+20)] call bis_fnc_taskPatrol;
	for "_i" from 1 to (floor random 4+2) do
	{
		_enemySpawned = _enemyGroup3 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
		[_enemySpawned,false] call bro_fnc_setSkills;
		SpawnedEnemyMasterList pushBack _enemySpawned;
	};
	[_enemyGroup3, (getPosATL _x), (floor random 80+60)] call bis_fnc_taskPatrol;
	if (count armedVics != 0 && count allVics != 0) then 
	{
		_nearbyRoadList = nearestTerrainObjects [(selectRandom _selectedObjBuildings), ["ROAD", "MAIN ROAD", "TRACK","TRAIL"], 350];
		_nearbyRoad = _nearbyRoadList select 0;
		_nearbyRoad2 = _nearbyRoadList select 3;
		_nearbyRoad3 = _nearbyRoadList select 5;
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
if (count armedVics == 0 && count allVics == 0) then 
{
	systemChat format ["%1 has no eligible vehicles to spawn.",_selectedDisplayName];
};
systemChat format ["%1 new objectives created.",count Objectives];

// Reinforcements test:
// Spawn a trigger where, when Blufor is detected by faction, it runs the reinforcements function and deletes the trigger:
if (!isNil "ObjectiveTriggers") then
{
	systemChat format ["Removed: %1 reinf triggers.",count ObjectiveTriggers];
	{deleteVehicle _x} forEach ObjectiveTriggers;
};
_facDetect = "";
switch (_factionSide) do {
	case east: {_facDetect = "EAST D"};
	case independent: {_facDetect = "GUER D"};
	default {_facDetect = "EAST D"};
};
ObjectiveTriggers = [];
allReinforcements = [];
{
	private _ReinfTrg = createTrigger ["EmptyDetector",getPos _x];
	private _triggerString = format ["[%1,%2] remoteExec ['bro_fnc_reinforceObj', 2];systemChat 'Detector fired';",getPos _x,str _factionClass];
	_ReinfTrg setTriggerArea [150, 150, 0, true];
	_ReinfTrg setTriggerActivation ["WEST",_facDetect,false];
	_ReinfTrg setTriggerStatements ["this && west countSide thisList > 0 ",_triggerString,""];
	ObjectiveTriggers pushBack _ReinfTrg;
} forEach Objectives;