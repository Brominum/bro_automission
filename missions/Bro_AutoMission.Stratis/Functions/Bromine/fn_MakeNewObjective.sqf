// Encapsulate it all here because I'm dumb and to prevent executing this locally:
if (isServer) then {
	// Cleanup from previous mission, remove things made at initialization:
	{playSound3D [(selectRandom [getMissionPath "sounds\radio1.ogg",getMissionPath "sounds\radio2.ogg",getMissionPath "sounds\radio3.ogg",getMissionPath "sounds\radio4.ogg"]), _x];} forEach [Bro_Generator,heli_1,heli_2,heli_3];
	{deleteVehicle _x} forEach units regrp;
	{deleteVehicle _x} forEach units regrp2;
	{deleteVehicle _x} forEach units regrp3;
	{deleteVehicle _x} forEach units regrp4;
	{deleteVehicle _x} forEach units regrp5;
	{deleteVehicle _x} forEach units civgrp;
	{deleteVehicle _x} forEach units civgrp2;
	{deleteVehicle _x} forEach units civgrp3;
	{deleteVehicle _x} forEach units civgrp4;
	{deleteVehicle _x} forEach allDeadMen;
	{deleteMarker _x} forEach ["ObjMarker1","ObjMarker2","ObjMarker3","ObjMarker4"];
	{if (alive _x) then {deleteVehicle _x}} forEach [objVic,objVic2,objVic3,Reinfvic];
	while {(count (waypoints regrp)) > 0} do {deleteWaypoint ((waypoints regrp) select 0);};
	while {(count (waypoints regrp2)) > 0} do {deleteWaypoint ((waypoints regrp2) select 0);};
	while {(count (waypoints regrp3)) > 0} do {deleteWaypoint ((waypoints regrp3) select 0);};
	while {(count (waypoints regrp4)) > 0} do {deleteWaypoint ((waypoints regrp4) select 0);};
	while {(count (waypoints regrp5)) > 0} do {deleteWaypoint ((waypoints regrp5) select 0);};
	ObjMarker1 = createMarker ["ObjMarker1",[-50000,-50000,0]];
	ObjMarker2 = createMarker ["ObjMarker2",[50000,50000,0]];
	ObjMarker3 = createMarker ["ObjMarker3",[-50000,50000,0]];
	ObjMarker4 = createMarker ["ObjMarker4",[50000,-50000,0]];
	// Select a random building from the array variable that was created in InitServer.sqf:
	tgtBuilding1 = selectRandom BuildingMasterList;
	// Now get an unfiltered array of all buildings within 1 kilometer of tgtBuilding1:
	NearbyBuildings = nearestObjects [tgtBuilding1,["HOUSE"],1000,true];
	private _buildingsToDelete = [];
	{
		if (count (_x buildingPos -1) == 0) then 
		{
			_buildingsToDelete pushBack _x;
		};
	} forEach NearbyBuildings;
	// Remove all buildings that are in _buildingsToDelete from NearbyBuildings
	{
		_deleteBuilding = NearbyBuildings find _x;
		if (_deleteBuilding > -1) then {
			NearbyBuildings deleteAt _deleteBuilding;
		};
	} forEach _buildingsToDelete;
	// Redefine tgtBuilding1 using this new array:
	tgtBuilding1 = NearbyBuildings select 0;
	// Now select the 3 nearest buildings to tgtBuilding1 from the Array we just cleaned up earlier:
	tgtBuilding2 = ((NearbyBuildings find tgtBuilding1) + 1);
	tgtBuilding2 = (NearbyBuildings select tgtBuilding2);
	tgtBuilding3 = ((NearbyBuildings find tgtBuilding1) + 2);
	tgtBuilding3 = (NearbyBuildings select tgtBuilding3);
	tgtBuilding4 = ((NearbyBuildings find tgtBuilding1) + 3);
	tgtBuilding4 = (NearbyBuildings select tgtBuilding4);
	// Spawn the objective cache in one of the buildings, in a random spot:
	if (alive objCache) then {deleteVehicle objCache};
	objCache = "Box_IED_Exp_F" createVehicle (selectRandom ((selectRandom [tgtBuilding1,tgtBuilding2,tgtBuilding3,tgtBuilding4]) buildingPos -1));
	while {!alive objCache} do {objCache = "Box_IED_Exp_F" createVehicle (selectRandom ((selectRandom [tgtBuilding1,tgtBuilding2,tgtBuilding3,tgtBuilding4]) buildingPos -1))};
	objCache setVehiclePosition [objCache,[],0,"CAN_COLLIDE"];
	// Pick 3 road pieces close to the 1st target building for later:
	_nearbyRoadList = nearestTerrainObjects [(selectRandom [tgtBuilding1,tgtBuilding2,tgtBuilding3,tgtBuilding4]), ["ROAD", "MAIN ROAD", "TRACK","TRAIL"], 350];
	_nearbyRoad = _nearbyRoadList select 0;
	_nearbyRoad2 = _nearbyRoadList select 3;
	_nearbyRoad3 = _nearbyRoadList select 5;
	// Count how many garrison positions there are in each building and store in a variable for the next step:
	nbpos = tgtBuilding1 buildingPos -1;
	nbpos2 = tgtBuilding2 buildingPos -1;
	nbpos3 = tgtBuilding3 buildingPos -1;
	nbpos4 = tgtBuilding4 buildingPos -1;
	// For each garrison position in each building, spawn an enemy on every 2nd one and delete that spot from the list to prevent spawning enemies inside of enemies:
	for [{_i = 1},{_i<=(count nbpos - 1)},{_i=_i+2}] do
	{
		_nextpos = nbpos deleteAt floor random (count nbpos);
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp createUnit [_selectedRandomUnit,_nextpos,[],0,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.05];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.15];_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos2 - 1)},{_i=_i+2}] do
	{
		_nextpos2 = nbpos2 deleteAt floor random (count nbpos2);
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp createUnit [_selectedRandomUnit,_nextpos2,[],0,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.05];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.15];_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos3 - 1)},{_i=_i+2}] do
	{
		_nextpos3 = nbpos3 deleteAt floor random (count nbpos3);
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp createUnit [_selectedRandomUnit,_nextpos3,[],0,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.05];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.15];_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos4 - 1)},{_i=_i+2}] do
	{
		_nextpos4 = nbpos4 deleteAt floor random (count nbpos4);
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp createUnit [_selectedRandomUnit,_nextpos4,[],0,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.05];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.15];_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	// Create 2 patrols outside of the building, patrolling at 20 and 40 meter distances:
	for "_i" from 1 to 4 do
	{
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp2 createUnit [_selectedRandomUnit,_nearbyRoad,[],10,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.1];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.25];_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	[regrp2, (getPosATL tgtBuilding1), 30] call bis_fnc_taskPatrol;
	for "_i" from 1 to 4 do
	{
		_selectedRandomUnit = selectRandom enemyInfantry;
		_finalRandomUnit = regrp3 createUnit [_selectedRandomUnit,_nearbyRoad2,[],10,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.1];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.25];_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	[regrp3, (getPosATL tgtBuilding1), 40] call bis_fnc_taskPatrol;
	// Spawn 2 empty vics on the road nearby, and 1 with a 25% chance to have enemies in it
	_randomVicLol = selectRandom armedVics;
	_randomVicLol2 = selectRandom allVics;
	_randomVicLol3 = selectRandom allVics;
	switch ([1,2] selectRandomWeighted [0.75,0.25]) do
	{
		case 1: {_result = [getPosATL _nearbyRoad,random 360,_randomVicLol, regrp3] call BIS_fnc_spawnVehicle;ObjVic = _result select 0};
		case 2: {objVic = createVehicle [_randomVicLol,_nearbyRoad];ObjVic setDir random 360;[regrp3, (getPosATL tgtBuilding1), 50] call bis_fnc_taskPatrol;};
	};
	objVic2 = createVehicle [_randomVicLol2,_nearbyRoad2];
	ObjVic2 setDir random 360;
	objVic3 = createVehicle [_randomVicLol3,_nearbyRoad3];
	ObjVic3 setDir random 360;
	// Spawn markers on target buildings:
	{
		_x setMarkerShape "ICON"; 
		_x setMarkerType "mil_triangle"; 
		_x setMarkerColor "ColorOPFOR";
	} forEach [ObjMarker1,ObjMarker2,ObjMarker3,ObjMarker4];
	/*
	ObjMarker2 setMarkerShape "ICON"; 
	ObjMarker2 setMarkerType "mil_triangle"; 
	ObjMarker2 setMarkerColor "ColorOPFOR"; 
	ObjMarker3 setMarkerShape "ICON"; 
	ObjMarker3 setMarkerType "mil_triangle"; 
	ObjMarker3 setMarkerColor "ColorOPFOR"; 
	ObjMarker4 setMarkerShape "ICON"; 
	ObjMarker4 setMarkerType "mil_triangle"; 
	ObjMarker4 setMarkerColor "ColorOPFOR";
	*/
	"ObjMarker1" setMarkerPos tgtBuilding1;
	"ObjMarker2" setMarkerPos tgtBuilding2;
	"ObjMarker3" setMarkerPos tgtBuilding3;
	"ObjMarker4" setMarkerPos tgtBuilding4;
	// Spawn a trigger where, when Blufor is detected by Opfor, it runs the reinforcements function, turns on pathing for all civs (run away!), and deletes the trigger to prevent doubling up:
	ReinfTrg = createTrigger ["EmptyDetector", getPos tgtBuilding1];
	ReinfTrg setTriggerArea [150, 150, 0, false];
	ReinfTrg setTriggerActivation ["WEST", "EAST D", true];
	ReinfTrg setTriggerStatements
	[
		"this",
		"remoteExec ['bro_fnc_reinforcements', 2];{_x enableAI 'PATH';} forEach units civgrp1;{_x enableAI 'PATH';} forEach units civgrp2;{_x enableAI 'PATH';} forEach units civgrp3;{_x enableAI 'PATH';} forEach units civgrp4;deleteVehicle ReinfTrg;",
		""
	];
	// 33% chance to spawn civillians on the objective buildings:
	switch ([1,2] selectRandomWeighted [0.33,0.67]) do
	{
		case 1: {[nbpos,nbpos2,nbpos3,nbpos4] remoteExec ["bro_fnc_CivilianAdder", 2];};
		case 2: {};
	};
};