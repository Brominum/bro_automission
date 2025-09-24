params ["_unit"];
_unit setBehaviour "SAFE";
_unit setunitpos "UP";
{_unit setSkill _x} forEach 
[
	["spotTime", 0.5],
	["aimingAccuracy", 0.1],
	["aimingShake", 0.25],
	["aimingSpeed", 0.3],
	["spotDistance", 0.5],
	["courage", 1.0],
	["commanding", 1.0],
	["general", 0.2]
];