class CfgPatches {
	class Bro_AutoMission {
		author="Brominum";
		name="Bromine's AutoMission";
		url="https://steamcommunity.com/id/Brominum/";
		requiredAddons[]= {"A3_Data_F_Loadorder","rhsusf_main","ace_common"};
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