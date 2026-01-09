params ["_objLocation","_factionClass"];
private _sideIndex = getNumber (configFile >> "CfgFactionClasses" >> _factionClass >> "side");
private _factionSide = [east, west, independent, civilian] select _sideIndex;
private _reinfGroup = createGroup _factionSide;
private _objHelper = "Sign_Arrow_Blue_F" createVehicle _objLocation;
private _reinfSpawn = [
	(getPos _objHelper select 0) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])]),
	(getPos _objHelper select 1) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])])
];
while {surfaceIsWater _reinfSpawn} do {
	_reinfSpawn = [
		(getPos _objHelper select 0) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])]),
		(getPos _objHelper select 1) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])])
	];
};
for "_i" from 1 to (floor random [4,8,15]) do {
	private _enemySpawned = _reinfGroup createUnit [(selectRandom enemyInfantry),_reinfSpawn,[],0,"CAN_COLLIDE"];
	[_enemySpawned,false] call bro_fnc_setSkills;
	allReinforcements pushBack _enemySpawned;
};
private _wp = _reinfGroup addWaypoint [getPosASL _objHelper,0];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "AWARE";
if (count armedVics > 0) then {
	private _nearbyRoadList = nearestTerrainObjects [_objHelper, ["ROAD", "MAIN ROAD", "TRACK", "TRAIL"], 1500];
	_nearbyRoadList sort false;
	if (((random [0,30,100]) random 1) < 0.3) then {
		private _reinfGroup2 = createGroup _factionSide;
		private _result = [(getPosATL (_nearbyRoadList select 0)),(getPos (_nearbyRoadList select 0)) getDir (getPos (_nearbyRoadList select 1)),(selectRandom armedVics), _reinfGroup2] call BIS_fnc_spawnVehicle;
		private _wp2 = _reinfGroup2 addWaypoint [getPosASL _objHelper,0];
		_wp2 setWaypointType "SAD";
		_wp2 setWaypointBehaviour "AWARE";
		allReinforcements pushBack (_result select 0);
		allReinforcements append (_result select 1);
	};
};
deleteVehicle _objHelper;