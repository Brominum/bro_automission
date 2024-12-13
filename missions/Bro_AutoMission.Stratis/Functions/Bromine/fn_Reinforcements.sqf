if (isServer) then {
	reinfSpawn = [(getPos tgtBuilding1 select 0) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])]),(getPos tgtBuilding1 select 1) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])])];
	isInWater = surfaceIsWater reinfSpawn;
	while {isInWater} do {
		reinfSpawn = [(getPos tgtBuilding1 select 0) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])]),(getPos tgtBuilding1 select 1) + (selectRandom [(random [200,400,600]),(random [200,400,600]),(random [-600,-400,-200]),(random [-600,-400,-200])])];
		isInWater = surfaceIsWater reinfSpawn;
	};
	for "_i" from 1 to (floor random [4,8,15]) do {
		_finalRandomUnit = regrp4 createUnit [(selectRandom enemyInfantry),reinfSpawn,[],0,"CAN_COLLIDE"];
		_finalRandomUnit setSkill ["spotTime", 0.5];_finalRandomUnit setSkill ["aimingAccuracy", 0.05];_finalRandomUnit setSkill ["aimingShake", 0.1];_finalRandomUnit setSkill ["aimingSpeed", 0.3];_finalRandomUnit setSkill ["spotDistance", 0.5];_finalRandomUnit setSkill ["courage", 1.0];_finalRandomUnit setSkill ["commanding", 1.0];_finalRandomUnit setSkill ["general", 0.15];_finalRandomUnit setBehaviour "AWARE";_finalRandomUnit setunitpos "UP";
	};
	[regrp4, (getPosATL tgtBuilding1)] call bis_fnc_taskAttack;

	_nearbyRoadList = nearestTerrainObjects [tgtBuilding1, ["ROAD", "MAIN ROAD", "TRACK", "TRAIL"], 1500]; 
	_nearbyRoadList sort false; 
	if (((random [0,30,100]) random 1) < 0.3) then {
		_result = [(getPosATL (_nearbyRoadList select 0)),(getPos (_nearbyRoadList select 0)) getDir (getPos (_nearbyRoadList select 1)),(selectRandom armedVics), regrp5] call BIS_fnc_spawnVehicle;
		ReinfVic = _result select 0;
		[regrp5, (getPosATL tgtBuilding1)] call bis_fnc_taskAttack;
	};
};