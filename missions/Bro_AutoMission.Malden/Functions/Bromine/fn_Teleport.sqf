openMap true;
onMapSingleClick "player setpos _pos;openMap false;[format ['%1 teleported to %2.',(name player),mapGridPosition player]] remoteExec ['systemChat',0];onMapSingleClick '';";