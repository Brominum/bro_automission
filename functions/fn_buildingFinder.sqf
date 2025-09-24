	params [["_garrCount",6]];
	systemChat format ["garrCount value: %1",_garrCount];	// DEBUG LINE
		if (_garrCount < 2) exitWith {
			systemChat "Garrison count needs to be 2 or higher. Function aborted.";
		};
		private _masterlist = nearestObjects [[(worldSize/2),(worldSize/2)],["HOUSE"],(worldSize / 2),true];
		private _b2del = [];
		private _bblackl = ["Land_Pier_F","Land_nav_pier_m_F","Land_Pier_small_F","Land_PierWooden_02_16m_F","Land_PierWooden_02_barrel_F","Land_PierWooden_02_hut_F","Land_PierWooden_01_10m_noRails_F","Land_PierWooden_01_16m_F","Land_PierWooden_01_dock_F","Land_PierWooden_01_hut_F","Land_PierWooden_01_ladder_F","Land_PierWooden_01_platform_F","Land_PierWooden_02_30deg_F","Land_dp_bigTank_F","Land_dp_bigTank_old_F","Land_StorageTank_01_large_F","Land_ContainerLine_03_F","Land_ContainerLine_02_F","Land_ContainerLine_01_F","Land_Warehouse_01_F","Land_Warehouse_02_F","Land_MultistoryBuilding_04_F","Land_MultistoryBuilding_01_F","Land_MultistoryBuilding_03_F","Land_SCF_01_storageBin_big_F","Land_SCF_01_storageBin_medium_F","Land_SCF_01_storageBin_small_F","Land_SCF_01_heap_bagasse_F","Land_Crane_F","Land_MobileCrane_01_F","Land_MobileCrane_01_hook_F","ContainerCrane_01"];
		{
			if ((count (_x buildingPos -1) <= _garrCount) || {((typeOf _x) in _bblackl)}) then 
			{
				_b2del pushBack _x;
			};
		} forEach _masterlist;
		{
			private _bDel = _masterlist find _x;
			_masterlist deleteAt _bDel;
		} forEach _b2del;
	_masterlist