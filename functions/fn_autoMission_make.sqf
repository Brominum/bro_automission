params ["_selectedDisplayName","_factionClass","_objCount","_enemyDensity"];
switch (_enemyDensity) do {
	case 0: {_enemyDensity = floor random 4+1};
	case 1: {_enemyDensity = 6};
	case 2: {_enemyDensity = 4};
	case 3: {_enemyDensity = 2};
	default {_enemyDensity = floor random 4+1};
};
private _sideIndex = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
private _factionSide = [east, west, independent, civilian] select _sideIndex;
if (([_factionSide, west] call BIS_fnc_sideIsEnemy) == false) then 
{
	_factionSide setFriend [west, 0];
	west setFriend [_factionSide, 0];
	systemChat format ["%1 is the selected faction, and is now hostile to BLUFOR.", _selectedDisplayName];
};
{deleteMarkerLocal _x} forEach allMapMarkers;
enemyInfantry = [];
{
	if 
	(
		getText (_x >> "faction") == _factionClass 
		&& {getNumber (_x >> "isMan") == 1} 
		&& {getNumber (_x >> "scope") == 2}
	) then 
	{
		enemyInfantry pushBack (configName _x);
	};
} forEach ("true" configClasses (configFile >> "CfgVehicles"));
private _allConfigs = configFile >> "CfgVehicles";
allVics = [];
{
	private _isMan = getNumber (_x >> "isMan") == 0;
	private _isCar = getText (_x >> "vehicleClass") == "Car";
	private _isPublic = getNumber (_x >> "scope") == 2;
	if (_isMan && _isCar && (getText (_x >> "faction") == _factionClass) && _isPublic) then 
	{
		allVics pushBack (configName _x);
	};
} forEach ("true" configClasses _allConfigs);
armedVics = [];
{
	private _isMan = getNumber (_x >> "isMan") == 0;
	private _isCar = getText (_x >> "vehicleClass") == "Car";
	private _isPublic = getNumber (_x >> "scope") == 2;
	if (_isMan && _isCar && (getText (_x >> "faction") == _factionClass) && _isPublic) then 
	{
		private _hasWeapons = false;
		private _turrets = _x >> "Turrets";
		for "_i" from 0 to (count _turrets - 1) do 
		{
			private _turret = _turrets select _i;
			private _weapons = getArray (_turret >> "weapons");
			if (count _weapons > 0) exitWith { _hasWeapons = true };
		};
		if (_hasWeapons) then 
		{
			armedVics pushBack (configName _x);
		};
	};
} forEach ("true" configClasses _allConfigs);
if (!isNil "ObjectiveCaches") then
{
	systemChat format ["Removing: %1 units, %2 caches, %3 vehicles.",count SpawnedEnemyMasterList,count ObjectiveCaches,count ObjectiveVehicles];
	{deleteVehicle _x} forEach ObjectiveCaches+SpawnedEnemyMasterList+ObjectiveVehicles;
	{
		deleteVehicleCrew _x;
	} forEach ObjectiveVehicles;
};
{deleteVehicle _x} forEach AllDeadMen;
_BuildingMasterList = [_enemyDensity] call bro_fnc_buildingFinder;
Objectives = [];
ObjectiveCaches = [];
ObjectiveVehicles = [];
for "_i" from 1 to _objCount do
{
	Objectives pushbackUnique (selectRandom _BuildingMasterList);
};
SpawnedEnemyMasterList = [];
{
/* Not needed?
	_enemyGroup = nil;
	_enemyGroup2 = nil;
	_enemyGroup3 = nil;
	_enemyGroup4 = nil;
*/
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
			_enemySpawned setSkill ["spotTime", 0.5];_enemySpawned setSkill ["aimingAccuracy", 0.01];_enemySpawned setSkill ["aimingShake", 0.5];_enemySpawned setSkill ["aimingSpeed", 0.3];_enemySpawned setSkill ["spotDistance", 0.5];_enemySpawned setSkill ["courage", 1.0];_enemySpawned setSkill ["commanding", 1.0];_enemySpawned setSkill ["general", 0.15];_enemySpawned disableAI "PATH";_enemySpawned setBehaviour "SAFE";_enemySpawned setunitpos "UP";
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
		[_enemySpawned] call bro_fnc_setBasicSkills;
		SpawnedEnemyMasterList pushBack _enemySpawned;
	};
	[_enemyGroup2, (getPosATL _x), (floor random 25+20)] call bis_fnc_taskPatrol;
	for "_i" from 1 to (floor random 4+2) do
	{
		_enemySpawned = _enemyGroup3 createUnit [(selectRandom enemyInfantry),_patrolSpawn,[],10,"CAN_COLLIDE"];
		[_enemySpawned] call bro_fnc_setBasicSkills;
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