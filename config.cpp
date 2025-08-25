class CfgPatches {
	class Bro_AutoMission {
		author="Brominum";
		name="Bromine's AutoMission";
		url="https://steamcommunity.com/id/Brominum/";
		requiredAddons[]= {"A3_Data_F_Loadorder","ace_common"};
		requiredVersion=1.60;
	};
};
class CfgMissions {
	class MPMissions {
		class bro_automission_stratis {
			directory="bro_automission\missions\bro_automission.stratis";
			overviewText="AutoMission scenario: A multiplayer-compatible basic mission generator with support for up to 51 players. 2 Zeus slots included.";
			briefingName="AutoMission: Stratis";
			overviewPicture="bro_automission\icon_ca.paa";
		};
		class bro_automission_altis {
			directory="bro_automission\missions\bro_automission.altis";
			overviewText="AutoMission scenario: A multiplayer-compatible basic mission generator with support for up to 51 players. 2 Zeus slots included.";
			briefingName="AutoMission: Altis";
			overviewPicture="bro_automission\icon_ca.paa";
		};
		class bro_automission_malden {
			directory="bro_automission\missions\bro_automission.malden";
			overviewText="AutoMission scenario: A multiplayer-compatible basic mission generator with support for up to 51 players. 2 Zeus slots included.";
			briefingName="AutoMission: Malden 2035";
			overviewPicture="bro_automission\icon_ca.paa";
		};
	};
};
class CfgFunctions {
	class Bro {
		class Automission {
			class Automission_Module {
				file="\bro_automission\functions\automission\fn_automission_module.sqf";
			};
		};
	};
};
class CfgVehicles {
	class ModuleIRGrenade_F;
	class Bro_Automission_Module: ModuleIRGrenade_F
	{
		author="Bromine";
		scope=2;
		scopeCurator=2;
		displayName="Automission Generator";
		portrait="\a3\modules_f_curator\data\portraitobjective_ca.paa";
		category="Objectives";
		function="Bro_fnc_automission_module";
		is3DEN=0;
		ammo="";
	};
};