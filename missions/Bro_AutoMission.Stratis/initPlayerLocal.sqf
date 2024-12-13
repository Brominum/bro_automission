// Define our functions and what they actually do when executed:
bro_fnc_teleport = {
		openMap [true,true];
		onMapSingleClick "player setpos _pos;openMap [false,false];[format ['%1 teleported to %2.',(name player),mapGridPosition player]] remoteExec ['systemChat',0];onMapSingleClick '';";
};
bro_fnc_selfheal = {
		[player] call ACE_MEDICAL_TREATMENT_fnc_fullHealLocal;
		playSound3D ["a3\sounds_f\characters\ingame\ainvppnemstpslaywpstdnon_medicout.wss",player, false, getPosASL player, 5, 1, 7];
		[format ['%1 self-healed.',(name player)]] remoteExec ['systemChat',0];
};
bro_fnc_arsenal = {
		[player, player, true] call ace_arsenal_fnc_openBox;
		[format ['%1 opened arsenal.',(name player)]] remoteExec ['systemChat',0];
};
// Make the ACE actions that will call those functions, and only when global variable "bro_allowactions" is TRUE:
_actionTeleport = ["Teleport","<t color='#f2bc04'>Teleport Self</t>","a3\modules_f\data\iconstrategicmapinit_ca.paa",{call bro_fnc_teleport},{bro_allowactions}] call ace_interact_menu_fnc_createAction;
_actionHealself = ["Heal Self","<t color='#f2bc04'>Heal Self</t>","a3\modules_f_curator\data\iconflare_ca.paa",{call bro_fnc_selfheal},{bro_allowactions}] call ace_interact_menu_fnc_createAction;
_actionArsenal = ["Arsenal","<t color='#f2bc04'>Open Arsenal</t>","a3\missions_f_gamma\data\img\iconmptypeseize_ca.paa",{call bro_fnc_arsenal},{bro_allowactions}] call ace_interact_menu_fnc_createAction;
// Add the ACE actions to the self-interact menu under Equipment:
[player, 1, ["ACE_SelfActions","ACE_Equipment"],_actionTeleport] call ace_interact_menu_fnc_addActionToObject;
[player, 1, ["ACE_SelfActions","ACE_Equipment"],_actionHealself] call ace_interact_menu_fnc_addActionToObject;
[player, 1, ["ACE_SelfActions","ACE_Equipment"],_actionArsenal] call ace_interact_menu_fnc_addActionToObject;