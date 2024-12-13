// Everything in this script happens ONCE when the server loads the mission.
// You may edit the types of enemies and civillians it will spawn in these 4 variables:
enemyInfantry =  
[ 
	"O_G_Soldier_A_F", 
	"O_G_Soldier_AR_F", 
	"O_G_medic_F", 
	"O_G_engineer_F", 
	"O_G_Soldier_exp_F", 
	"O_G_Soldier_M_F", 
	"O_G_officer_F", 
	"O_G_Soldier_F", 
	"O_G_Soldier_LAT2_F", 
	"O_G_Soldier_lite_F", 
	"O_G_Soldier_SL_F"
];
armedVics =
[
	"O_G_Offroad_01_armed_F",
	"O_G_Offroad_01_armed_F",
	"O_G_Offroad_01_AT_F"
];
allVics =
[
	"O_G_Offroad_01_armed_F", 
	"O_G_Offroad_01_AT_F", 
	"O_G_Van_01_transport_F", 
	"O_G_Van_02_vehicle_F", 
	"O_G_Offroad_01_F", 
	"O_G_Quadbike_01_F"
];
randomCivClass = "C_Man_casual_4_v2_F";
// ---------- Don't touch below this line ----------
// Most important part these next few lines: Create the list of ALL buildings on the map derived from HOUSE!
BuildingMasterList = nearestObjects [[(worldSize/2),(worldSize/2)],["HOUSE"],(worldSize / 2),true];
// Make a list of buildings with no usable garrison positions and stick it into _buildingsToDelete:
private _buildingsToDelete = [];
{
    if (count (_x buildingPos -1) == 0) then 
    {
        _buildingsToDelete pushBack _x;
    };
} forEach BuildingMasterList;
// Remove all buildings that are in _buildingsToDelete from BuildingMasterList
{
    _deleteBuilding = BuildingMasterList find _x;
    if (_deleteBuilding > -1) then {
        BuildingMasterList deleteAt _deleteBuilding;
    };
} forEach _buildingsToDelete;
// Create blank groups, markers, and objects so no fancy extra code is needed in the actual functions:
regrp = createGroup east; 
regrp2 = createGroup east; 
regrp3 = createGroup east; 
regrp4 = createGroup east; 
regrp5 = createGroup east; 
civgrp = createGroup civilian; 
civgrp2 = createGroup civilian; 
civgrp3 = createGroup civilian; 
civgrp4 = createGroup civilian;
ObjMarker1 = createMarker ["ObjMarker1",[-50000,-50000,0]]; 
ObjMarker2 = createMarker ["ObjMarker2",[-50000,-50000,0]]; 
ObjMarker3 = createMarker ["ObjMarker3",[-50000,-50000,0]]; 
ObjMarker4 = createMarker ["ObjMarker4",[-50000,-50000,0]];
objCache = createVehicle ["Land_HelipadEmpty_F",[0,0,0]];
objVic = createVehicle ["Land_HelipadEmpty_F",[0,0,0]];
objVic2 = createVehicle ["Land_HelipadEmpty_F",[0,0,0]];
objVic3 = createVehicle ["Land_HelipadEmpty_F",[0,0,0]];
ReinfVic = createVehicle ["Land_HelipadEmpty_F",[0,0,0]];
// Add our actions to these objects with bespoke variable names placed in the editor. Do it on the server only so it's JIP without duplicates:
[Bro_Generator] remoteExec ["bro_fnc_actionsetup",0,true];