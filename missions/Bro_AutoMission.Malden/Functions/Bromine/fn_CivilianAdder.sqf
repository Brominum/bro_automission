// Spawn civillians. Same shit from MakeNewObjective:
if (isServer) then {
	for [{_i = 1},{_i<=(count nbpos - 1)},{_i=_i+(selectRandom [3,4,5,5,5])}] do
	{
		_nextpos = nbpos deleteAt floor random (count nbpos);
		_finalRandomUnit = civgrp createUnit [randomCivClass,_nextpos,[],0,"CAN_COLLIDE"];
		_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos2 - 1)},{_i=_i+(selectRandom [3,4,5,5,5])}] do
	{
		_nextpos = nbpos2 deleteAt floor random (count nbpos2);
		_finalRandomUnit = civgrp2 createUnit [randomCivClass,_nextpos,[],0,"CAN_COLLIDE"];
		_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos3 - 1)},{_i=_i+(selectRandom [3,4,5,5,5])}] do
	{
		_nextpos = nbpos3 deleteAt floor random (count nbpos3);
		_finalRandomUnit = civgrp3 createUnit [randomCivClass,_nextpos,[],0,"CAN_COLLIDE"];
		_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
	for [{_i = 1},{_i<=(count nbpos4 - 1)},{_i=_i+(selectRandom [3,4,5,5,5])}] do
	{
		_nextpos = nbpos4 deleteAt floor random (count nbpos4);
		_finalRandomUnit = civgrp4 createUnit [randomCivClass,_nextpos,[],0,"CAN_COLLIDE"];
		_finalRandomUnit disableAI "PATH";_finalRandomUnit setBehaviour "SAFE";_finalRandomUnit setunitpos "UP";
	};
};