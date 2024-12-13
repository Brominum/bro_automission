params ["_newVehicle"];
[_newVehicle, true] call ace_arsenal_fnc_initBox;

[ 
	_newVehicle, 
	"<t size='1.2' color='#AAFF00'><img image='\a3\ui_f\data\map\vehicleicons\iconlogic_ca.paa'/>Request New Objective</t>", 
	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", 
	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", 
	"true", 
	"true", 
	{}, 
	{}, 
	{
		remoteExec ["bro_fnc_MakeNewObjective", 2];
		[format ['%1 requested a new objective.',(name player)]] remoteExec ['systemChat',0];
	}, 
	{}, 
	[], 
	2.5, 
	0, 
	false, 
	false 
] call BIS_fnc_holdActionAdd; 

[ 
	_newVehicle, 
	"<t size='1.2' color='#ff0000'><img image='\a3\characters_f\data\ui\icon_medic_ca.paa'/>Heal Self</t>", 
	"\a3\characters_f\data\ui\icon_medic_ca.paa", 
	"\a3\characters_f\data\ui\icon_medic_ca.paa", 
	"true", 
	"true", 
	{}, 
	{}, 
	{ 
		[player] call ACE_MEDICAL_TREATMENT_fnc_fullHealLocal;
		[format ['%1 healed up.',(name player)]] remoteExec ['systemChat',0];
		playSound3D [(selectRandom [getmissionpath "sounds\bandage.ogg",getmissionpath "sounds\inject.ogg",getmissionpath "sounds\medkit.ogg"]),player, false, getPosASL player, 5, 1, 7]; 
	}, 
	{}, 
	[], 
	0.1, 
	0, 
	false, 
	false 
] call BIS_fnc_holdActionAdd;

[ 
	_newVehicle, 
	"<t size='1.2' color='#0096FF'><img image='\a3\ui_f\data\igui\cfg\vehicletoggles\vtoliconon_ca.paa'/>Teleport Self</t>", 
	"\a3\ui_f\data\igui\cfg\vehicletoggles\vtoliconon_ca.paa", 
	"\a3\ui_f\data\igui\cfg\vehicletoggles\vtoliconon_ca.paa", 
	"true", 
	"true", 
	{}, 
	{}, 
	{player call bro_fnc_teleport}, 
	{}, 
	[], 
	2.5, 
	0, 
	false, 
	false 
] call BIS_fnc_holdActionAdd;