class CfgPatches {
	class Bro_AutoMission {
		author="Brominum";
		name="[Bro] AutoMission Tool";
		url="https://steamcommunity.com/id/Brominum/";
		requiredAddons[]= {"A3_Data_F_Loadorder","ace_common","cba_main"};
		requiredVersion=1.60;
	};
};
class CfgEditorCategories {
	class Bro_Automission_EdCat {
		displayName = "AutoMission [Bromine]";
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
class CfgFunctions  {
	class bro  {
		class bro_automission {
			file = "\Bro_Automission\functions";
			class autoMission_make {};
			class autoMission_select {};
			class buildingFinder {};
			class setSkills {};
			class reinforceObj {};
		};
	};
};
class CfgVehicles {
	class Land_Laptop_unfolded_F;
	class ModuleIRGrenade_F;
	class Bro_Automission_Module: ModuleIRGrenade_F {
		author="Bromine";
		scope=2;
		scopeCurator=2;
		displayName="Automission Generator";
		portrait="\a3\modules_f_curator\data\portraitobjective_ca.paa";
		category="Objectives";
		function="bro_fnc_autoMission_select";
		is3DEN=0;
		ammo="";
	};
	class Bro_Automission_Laptop: Land_Laptop_unfolded_F {
		author="Bromine";
		scope=2;
		editorCategory="Bro_Automission_EdCat";
		displayName="AutoMission Laptop";
		hiddenSelectionsTextures[] = {"a3\missions_f_oldman\data\img\screens\millerntbscreen02_co.paa"};
		class EventHandlers {
			init="(_this select 0) addAction [""<t color='#0066CC'>Mission Generator</t>"",{call bro_fnc_autoMission_select}];";
		};
	};
};