params [["_unit",objNull],["_disablePath",false]];
if (isNull _unit) exitWith {
	systemChat "WARNING: setSkills called with null unit.";
};
if (!alive _unit) exitWith {
	systemChat "WARNING: setSkills called on dead unit.";
};
if (_disablePath) then {
	_unit disableAI "PATH";
};
_unit setBehaviour "SAFE";
_unit setunitpos "UP";
{
	_unit setSkill _x;
} forEach [
	["spotTime", 0.5],
	["aimingAccuracy", 0.2],
	["aimingShake", 0.25],
	["aimingSpeed", 0.3],
	["spotDistance", 0.5],
	["courage", 1.0],
	["commanding", 1.0],
	["general", 0.2]
];