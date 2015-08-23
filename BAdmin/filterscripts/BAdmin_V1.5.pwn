#include <a_samp>
#include <DOF2>
#include <zcmd>
#include <sscanf2>
#include <YSI\y_va>
#include <foreach>

// ============================= [ Settings ] ==================================

#define aAntiCurse				(true)

#define MAX_LEVEL               10
#define MIN_PASS                3
#define MAX_DAYS                10
#define MIN_AMMO                100
#define MIN_DAYS                1
#define MAX_DAYS                10

// =============================================================================

// ============================= [ Defines ] ===================================

#define loop(%0)                	foreach(new %0 : Player)
#define KickEx(%0)                  SetTimerEx("KickPlayer", 100, false, "i", %0)
#define BFile(%0)               	pI[%0][File]
#define GetName(%0)             	pI[%0][Name]
#define GetIP(%0)               	pI[%0][Ip]
#define IsBAdmin(%0)            	pI[%0][Admin]
#define GetBLevel(%0)           	pI[%0][Admin_Level]
#define IsBLogged(%0)               pI[%0][Logged]
#define ConnectMessage(%0,%1)       if(!IsPlayerConnected(%1)) return SendClientMessage(%0, Orange, ".השחקן איננו מחובר")

// Colors ======================================

#define Red							0xFF0000FF
#define Yellow						0xFFFF00FF
#define Orange  					0xf28b04FF
#define Green 						0x34F803FF
#define Aqua 						0x16E4F5FF
#define Blue 						0x2BA0FFFF
#define Pink 						0xEE20FFFF
#define Purple 						0x8A0095FF
#define Gray 						0x7C7C7CFF
#define Brown   					0x7A6C37FF

#define red							"{FF0000}"
#define yellow						"{FFFF00}"
#define orange  					"{f28b04}"
#define green 						"{34F803}"
#define aqua 						"{16E4F5}"
#define blue 						"{2BA0FF}"
#define pink 						"{EE20FF}"
#define purple 						"{8A0095}"
#define gray 						"{7C7C7C}"
#define white 						"{FFFFFF}"
#define brown   					"{7a6c37}"

// =============================================

// Dialogs =====================================

#define DIALOG_MESSAGES             1510
#define DIALOG_EDIT_MESSAGES        1511
#define DIALOG_SHOW_MESSAGES        1512
#define DIALOG_SHOW_MESSAGE         1513
#define DIALOG_MESSAGE              1514
#define DIALOG_sSHOW                1515
#define DIALOG_AUTO_MESSAGE         1516
#define DIALOG_SHOW_aMESSAGE        1517
#define DIALOG_EDIT_MESSAGE			1518
#define DIALOG_EDIT_aMESSAGE        1519

// =============================================

// =============================================================================

// ============================ [ Forwards ]====================================

forward KickPlayer(playerid);
forward CountDown(playerid, number);
forward UnMute(playerid);
forward UnJail(playerid);
forward ServerMessages();

// =============================================================================

// ============================== [ News ] =====================================

enum pi
{
	Name[MAX_PLAYER_NAME+1],
	File[MAX_PLAYER_NAME+19],
	Ip[16],
	Password[128],
	MuteReason[28],
	JailReason[28],
	Admin_Level,
	Fail,
	pCDTimer,
	Warnings,
	MutedTimer,
	JailedTimer,
	AdminVehicle,
	EditMessage,
	bool: Admin,
	bool: Logged,
	bool: newAdmin,
	bool: ChangeLevel,
	bool: Muted,
	bool: Jailed,
	bool: Inv,
	bool: God
}

enum si
{
	Admins,
	CDTimer,
	showmessage
}

new
	pI[MAX_PLAYERS][pi],
	sI[si],
	g_String[256],
	Server_Message[5][128],
	Auto_Message[10][128],
	aWeaponNames[47][] =
	{
        {"Unarmed"},{"Brass Knuckles"},{"Golf Club"},{"Nite Stick"},{"Knife"},{"Baseball Bat"},{"Shovel"},{"Pool Cue"},{"Katana"},{"Chainsaw"},{"Purple Dildo"},
        {"Smal White Vibrator"},{"Large White Vibrator"},{"Silver Vibrator"},{"Flowers"},{"Cane"},{"Grenade"},{"Tear Gas"},{"Molotov Cocktail"},
        {""},{""},{""},
        {"9mm"},{"Silenced 9mm"},{"Desert Eagle"},{"Shotgun"},{"Sawn-off Shotgun"},{"Combat Shotgun"},{"Micro SMG"},{"MP5"},{"AK-47"},{"M4"},{"Tec9"},
        {"Country Rifle"},{"Sniper Rifle"},{"Rocket Launcher"},{"HS Rocket Launcher"},{"Flamethrower"},{"Minigun"},{"Satchel Charge"},{"Detonator"},
        {"Spraycan"},{"Fire Extinguisher"},{"Camera"},{"Nightvision Goggles"},{"Thermal Goggles"},{"Parachute"}
	},
	VehicleName[212][] =
	{
		"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster",
		"Stretch","Manana","Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto",
		"Taxi","Washington","Bobcat","Mr Whoopee","BF Injection","Hunter","Premier","Enforcer","Securicar","Banshee",
		"Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie","Stallion","Rumpo",
		"RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer",
		"Turismo","Speeder","Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer",
		"Pcj - 600","Faggio","Freeway","RC Baron","RC Raider","Glendale","Oceanic","Sanchez","Sparrow","Patriot",
		"Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","Zr3 50","Walton","Regina","Comet","Bmx",
		"Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo",
		"Greenwood","Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa",
		"RC Goblin","Hotring Racer A","Hotring Racer B","Bloodring Banger","Rancher","Super GT","Elegant",
		"Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain","Nebula","Majestic",
		"Buccaneer","Shamal","Hydra","Fcr - 900","Nrg - 500","Hpv - 1000","Cement Truck","Tow Truck","Fortune","Cadrona",
		"FBI Truck","Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight",
		"Streak","Vortex","Vincent","Bullet","Clover","Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob",
		"Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A","Monster B","Uranus",
		"Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight",
		"Trailer","Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford",
		"BF-400","Newsvan","Tug","Trailer A","Emperor","Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C",
		"Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)","Police Car (LVPD)","Police Ranger",
		"Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
		"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
	},
	Float:JailPositions[6][3] =
	{
		{197.3192, 175.1013, 1003.0234}, // LV 1
		{193.0444, 174.7908, 1003.0234}, // LV 2
		{198.6733, 162.1703, 1003.0300}, // LV 3
		{264.3686, 78.6028,  1001.0391}, // SF 1
		{264.3686, 77.6028,  1001.0391}, // SF 2
		{264.3686, 76.6028,  1001.0391}  // SF 3
	}
	;

// =============================================================================

public OnFilterScriptInit()
{
	new File:file = fopen("BAdmin/Messages/Server_Messages.txt", io_read);
	while(fread(file, g_String))
		split(g_String, Server_Message, '|');
	fclose(file);
	
	file = fopen("BAdmin/Messages/Auto_Messages.txt", io_read);
	while(fread(file, g_String))
		split(g_String, Auto_Message, '|');
	fclose(file);
	SetTimer("ServerMessages", 5*1000*60, true);
	loop(playerid)
	    OnPlayerConnect(playerid);
	return true;
}

public OnFilterScriptExit()
{
    new File:file = fopen("BAdmin/Messages/Server_Messages.txt", io_write);
    for(new i; i < 5; i++)
	{
	    format(g_String, sizeof g_String, "%s|", Server_Message[i]);
	    fwrite_utf8(file, g_String);
	}
	fclose(file);

    file = fopen("BAdmin/Messages/Auto_Messages.txt", io_write);
    for(new i; i < 10; i++)
	{
		format(g_String, sizeof g_String, "%s|", Auto_Message[i]);
	    fwrite_utf8(file, g_String);
	}
	fclose(file);
	loop(playerid)
	    OnPlayerDisconnect(playerid, 0);
	return DOF2_SaveFile();
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, GetName(playerid), MAX_PLAYER_NAME);
	GetPlayerIp(playerid, GetIP(playerid), 15);
	format(BFile(playerid), MAX_PLAYER_NAME+19, "BAdmin/Banned/%s.ini", GetName(playerid));
	if(DOF2_FileExists(BFile(playerid)))
	{
    	if(!DOF2_IsSet(BFile(playerid), "Days"))
			format(g_String, sizeof g_String, ""blue"Ban info:\nTime & Date: %s | %s\nUnban days left: .הבאן לא ירד\n\n"red"Admin: "white"%s\n"red"Reason: "white"%s\n"red"Your IP: "white"%s", DOF2_GetString(BFile(playerid), "Date"), DOF2_GetString(BFile(playerid), "Time"), DOF2_GetString(BFile(playerid), "Admin"), DOF2_GetString(BFile(playerid), "Reason"), GetIP(playerid));
		else
		{
		    new dates[11], date[3], days;
			getdate(date[2], date[1], date[0]);
			format(dates, sizeof dates, "%d.%d.%d", date[0], date[1], date[2]);
			DatesTime(DOF2_GetString(BFile(playerid), "Date"), dates, days);
			if(days < DOF2_GetInt(BFile(playerid), "Days"))
	    		format(g_String, sizeof g_String, ""blue"Ban info:\nTime & Date: %s | %s\nUnban days left: %i\n\n"red"Admin: "white"%s\n"red"Reason: "white"%s\n"red"Your IP: "white"%s", DOF2_GetString(BFile(playerid), "Date"), DOF2_GetString(BFile(playerid), "Time"), DOF2_GetInt(BFile(playerid), "Days") - days, DOF2_GetString(BFile(playerid), "Admin"), DOF2_GetString(BFile(playerid), "Reason"), GetIP(playerid));
			else
				DOF2_RemoveFile(BFile(playerid));
		}
		ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""gray".אתה בבאן", g_String, "יציאה", "");
	    return KickEx(playerid);
	}
	
	format(BFile(playerid), MAX_PLAYER_NAME+11, "BAdmin/%s.ini", GetName(playerid));
	
	// ======= Load data:
	
	if(!DOF2_FileExists(BFile(playerid)))
	{
		DOF2_CreateFile(BFile(playerid));
		DOF2_SetBool(BFile(playerid), "Admin", false);
		DOF2_SetInt(BFile(playerid), "Admin_Level", 0);
		DOF2_SetBool(BFile(playerid), "Logged", false);
	    return DOF2_SetString(BFile(playerid), "LoggedIP", GetIP(playerid));
	}
	
	IsBAdmin(playerid) = DOF2_GetBool(BFile(playerid), "Admin");
	if(IsBAdmin(playerid))
	{
		if(DOF2_IsSet(BFile(playerid), "Days"))
		{
		    new dates[11], date[3], days;
			getdate(date[2], date[1], date[0]);
			format(dates, sizeof dates, "%d.%d.%d", date[0], date[1], date[2]);
			DatesTime(DOF2_GetString(BFile(playerid), "Date"), dates, days);
			if(days >= DOF2_GetInt(BFile(playerid), "Days"))
			{
			    GetBLevel(playerid) = 0;
				IsBLogged(playerid) = false;
				IsBAdmin(playerid) = false;
				DOF2_Unset(BFile(playerid), "Days");
				DOF2_Unset(BFile(playerid), "Date");
				return SendClientMessage(playerid, Pink, ".ירדת מדרגת האדמין שלך אוטומטית מכיוון שהיית אדמין זמני וכעת אתה שחקן רגיל");
			}
		}
	    strcpy(pI[playerid][Password], DOF2_GetString(BFile(playerid), "Password"), 128);
		IsBLogged(playerid) = DOF2_GetBool(BFile(playerid), "Logged");
		if(IsBLogged(playerid))
		{
			if(!strcmp(GetIP(playerid), DOF2_GetString(BFile(playerid), "LoggedIP")))
			{
			    GetBLevel(playerid) = DOF2_GetInt(BFile(playerid), "Admin_Level");
			    SendClientMessage(playerid, Orange, ".התחברת למערכת האדמינים אוטומטית לפי כתובת האייפי שלך");
			}
			else
			{
			    IsBLogged(playerid) = false;
				SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
			}
		}
	}
	return true;
}

public OnPlayerDisconnect(playerid, reason)
{
    format(BFile(playerid), MAX_PLAYER_NAME+12, "BAdmin/%s.ini", GetName(playerid));
	DOF2_SetBool(BFile(playerid), "Admin", IsBAdmin(playerid));
	if(IsBAdmin(playerid))
	{
	    DOF2_SetString(BFile(playerid), "Password", pI[playerid][Password]);
	    DOF2_SetBool(BFile(playerid), "Logged", IsBLogged(playerid));
		if(IsBLogged(playerid))
		{
			DOF2_SetString(BFile(playerid), "LoggedIP", GetIP(playerid));
			DOF2_SetInt(BFile(playerid), "Admin_Level", GetBLevel(playerid));
		}
	}
	// ==================
	pI[playerid][Fail] = 0;
	pI[playerid][Warnings] = 0;
	return DOF2_SaveFile();
}

public OnPlayerText(playerid, text[])
{
	if(pI[playerid][Muted]) return SendClientMessage(playerid, Red, "/Muted | .אתה מושתק"), false;
	#if aAntiCurse
		new
			AntiCurse[][] =
			{
				{"בן זונה"},
				{"בת זונה"},
				{"זונה"},
				{"שרמוטה"},
				{"מזדיין"},
				{"קוקסינל"},
				{"מיזדיין"},
				{"אוטיסט"},
				{"טיפש"},
				{"דביל"},
				{"אידיוט"}
			}
		;
	    for(new i; i < sizeof AntiCurse; i++) if(strfind(text[0], AntiCurse[i], true) != -1)
		{
			pI[playerid][Warnings]++;
			if(pI[playerid][Warnings] == 3)
			{
				Message(playerid, Yellow, "\"%s\" has been kicked by the server. (Reason: קללות)", GetName(playerid));
				return KickEx(playerid), false;
			}
			pI[playerid][Muted] = true;
			strcpy(pI[playerid][MuteReason], "קללה", 5);
			pI[playerid][MutedTimer] = SetTimerEx("UnMute", 3*1000*60, false, "i", playerid);
			return Message(playerid, Yellow, "\"%s\" has been muted by the server for 3 minutes. (Reason: קללה)", GetName(playerid)), false;
		}
	#endif
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new string[128];
	switch(dialogid)
	{
		case DIALOG_EDIT_MESSAGES:
		{
		    if(!response) return true;
		    switch(listitem)
		    {
		        case 0:
		        {
		            for(new i; i < 5; i++)
		            {
		            	format(g_String, sizeof g_String, "%s\n", Server_Message[i]);
		            	strcat(string, g_String);
					}
		            return ShowPlayerDialog(playerid, DIALOG_SHOW_MESSAGES, DIALOG_STYLE_LIST, "לוח מודעות", string, "המשך", "חזור");
				}
		        case 1:
		        {
		            for(new i; i < 10; i++)
		            {
		            	format(g_String, sizeof g_String, "%s\n", Auto_Message[i]);
		            	strcat(string, g_String);
					}
		            return ShowPlayerDialog(playerid, DIALOG_SHOW_MESSAGE, DIALOG_STYLE_LIST, "הודעות אוטומטיות", string, "המשך", "חזור");
		        }
		    }
		    return true;
		}
		case DIALOG_SHOW_MESSAGE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_EDIT_MESSAGES, DIALOG_STYLE_LIST, "עריכת הודעות", "עריכת לוח מודעות\nעריכת הודעות אוטומטיות", "המשך", "יציאה");
			pI[playerid][EditMessage] = listitem;
			return ShowPlayerDialog(playerid, DIALOG_EDIT_aMESSAGE, DIALOG_STYLE_LIST, "עריכת הודעה", "עריכת הודעה\nשלח הודעה זו עכשיו", "המשך", "חזרה");
		}
		case DIALOG_EDIT_aMESSAGE:
		{
		    if(!response)
		    {
		        for(new i; i < 10; i++)
		        {
		        	format(g_String, sizeof g_String, "%s\n", Auto_Message[i]);
		        	strcat(string, g_String);
				}
				return ShowPlayerDialog(playerid, DIALOG_SHOW_MESSAGES, DIALOG_STYLE_LIST, "לוח מודעות", string, "המשך", "חזור");
		    }
		    switch(listitem)
		    {
		        case 0:
		            return ShowPlayerDialog(playerid, DIALOG_AUTO_MESSAGE, DIALOG_STYLE_INPUT, "עריכת הודעה", ":הכנס את ההודעה", "המשך", "חזרה");
				case 1:
				{
		    		Message(-1, Pink, "[Server Message] >> "white"%s", Auto_Message[pI[playerid][EditMessage]]);
	    			return sI[showmessage] = 0;
				}
		    }
		}
		case DIALOG_AUTO_MESSAGE:
		{
		    if(!response) return ShowPlayerDialog(playerid, DIALOG_EDIT_aMESSAGE, DIALOG_STYLE_LIST, "עריכת הודעה", "עריכת הודעה\nשלח הודעה זו עכשיו", "המשך", "חזרה");
			if(!strlen(inputtext))
				return ShowPlayerDialog(playerid, DIALOG_AUTO_MESSAGE, DIALOG_STYLE_INPUT, "עריכת הודעה", ""red":הכנס את ההודעה", "המשך", "חזרה");
			strcpy(Auto_Message[pI[playerid][EditMessage]], inputtext, strlen(inputtext)+1);
			format(g_String, sizeof g_String, ""white":שינת את הודעה מספר %i ל\n\n%s\n\n"blue"? האם ברצונך להארות את ההודעה כעת", pI[playerid][EditMessage]+1, inputtext);
			return ShowPlayerDialog(playerid, DIALOG_SHOW_aMESSAGE, DIALOG_STYLE_MSGBOX, "שינוי הודעה", g_String, "כן", "יציאה");
		}
		case DIALOG_SHOW_aMESSAGE:
		{
		    if(!response) return true;
		    Message(-1, Pink, "[Server Message] >> "white"%s", Auto_Message[pI[playerid][EditMessage]]);
	    	return sI[showmessage] = 0;
		}
		case DIALOG_SHOW_MESSAGES:
		{
		    if(!response) return ShowPlayerDialog(playerid, DIALOG_EDIT_MESSAGES, DIALOG_STYLE_LIST, "עריכת הודעות", "עריכת לוח מודעות\nעריכת הודעות אוטומטיות", "המשך", "יציאה");
			pI[playerid][EditMessage] = listitem;
			return ShowPlayerDialog(playerid, DIALOG_EDIT_MESSAGE, DIALOG_STYLE_LIST, "עריכת הודעה", "עריכת הודעה\nהראה את לוח המודעות עכשיו", "המשך", "חזרה");
		}
		case DIALOG_EDIT_MESSAGE:
		{
		    if(!response)
		    {
		        for(new i; i < 5; i++)
		        {
		        	format(g_String, sizeof g_String, "%s\n", Server_Message[i]);
		        	strcat(string, g_String);
				}
		        return ShowPlayerDialog(playerid, DIALOG_SHOW_MESSAGES, DIALOG_STYLE_LIST, "לוח מודעות", string, "המשך", "חזור");
		    }
		    switch(listitem)
		    {
		        case 0:
		            return ShowPlayerDialog(playerid, DIALOG_MESSAGE, DIALOG_STYLE_INPUT, "עריכת הודעה", ":הכנס את ההודעה", "המשך", "חזרה");
				case 1:
				{
				    ServerMessages();
					return SendClientMessage(playerid, -1, ".הראת את לוח המודעות");
				}
		    }
		}
		case DIALOG_MESSAGE:
		{
		    if(!response) return ShowPlayerDialog(playerid, DIALOG_EDIT_MESSAGE, DIALOG_STYLE_LIST, "עריכת הודעה", "עריכת הודעה\nהראה את לוח המודעות עכשיו", "המשך", "חזרה");
			if(!strlen(inputtext))
				return ShowPlayerDialog(playerid, DIALOG_MESSAGE, DIALOG_STYLE_INPUT, "עריכת הודעה", ""red":הכנס את ההודעה", "המשך", "חזרה");
			strcpy(Server_Message[pI[playerid][EditMessage]], inputtext, strlen(inputtext)+1);
			format(g_String, sizeof g_String, ""white":שינת את הודעה מספר %i ל\n\n%s\n\n"blue"? האם ברצונך להארות את לוח המודעות כעת", pI[playerid][EditMessage]+1, inputtext);
			return ShowPlayerDialog(playerid, DIALOG_sSHOW, DIALOG_STYLE_MSGBOX, "שינוי הודעה", g_String, "כן", "יציאה");
		}
		case DIALOG_sSHOW:
		{
		    if(!response) return true;
		    ServerMessages();
			return SendClientMessage(playerid, -1, ".הראת את לוח המודעות");
		}
	}
	return false;
}

// ============================= [ Commands ] ==================================

CMD:rconsetadmin(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return false;
	if(sscanf(params, "ri", params[0], params[1])) return SendClientMessage(playerid, -1, "/RconSetAdmin [Name/ID] [Level]");
	ConnectMessage(playerid, params[0]);
	if(params[1] > MAX_LEVEL) return Message(playerid, -1, "/RconSetAdmin [Name/ID] [Level (0 - %i)]", MAX_LEVEL);
	if(IsBAdmin(params[0]))
	{
		if(GetBLevel(params[0]) == params[1]) return SendClientMessage(playerid, -1, ".רמת האדמין של שחקן זה זהה");
		if(!params[1])
		{
		    if(DOF2_IsSet(BFile(playerid), "Days"))
			{
			    DOF2_Unset(BFile(playerid), "Days");
				DOF2_Unset(BFile(playerid), "Date");
			}
		    GetBLevel(params[0]) = 0;
			IsBLogged(params[0]) = false;
			IsBAdmin(params[0]) = false;
			GetBLevel(params[0]) = false;
			return SendClientMessage(params[0], Pink, ".האדמין הוריד את דרגת האדמין שלך וכעת אתה שחקן רגיל");
		}
		GetBLevel(params[0]) = params[1];
		IsBLogged(params[0]) = false;
		pI[params[0]][ChangeLevel] = true;
		return SendClientMessage(params[0], Yellow, "/ALogin האדמין שינה את רמת האדמין שלך ולכן תצטרך להתחבר שוב למערכת. - בכדי להתחבר למערכת הקש");
	}
	pI[params[0]][newAdmin] = true;
	IsBAdmin(params[0]) = true;
	GetBLevel(params[0]) = params[1];
	IsBLogged(params[0]) = false;
	Message(playerid, Aqua, "! לרמת אדמין %i %s העלאת את", params[1], GetName(params[0]));
	Message(params[0], Aqua, ".מזל טוב ! עלית לרמת אדמין %i", params[1]);
	return SendClientMessage(params[0], Aqua, "/ALogin בכדי להתחבר למערכת האדמינים הקש");
}

CMD:setadmin(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < MAX_LEVEL) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ri", params[0], params[1])) return SendClientMessage(playerid, -1, "/SetAdmin [Name/ID] [Level]");
	ConnectMessage(playerid, params[0]);
	if(params[1] > MAX_LEVEL) return Message(playerid, -1, "/SetAdmin [Name/ID] [Level (0 - %i)]", MAX_LEVEL);
	if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
	if(IsBAdmin(params[0]))
	{
		if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
		if(GetBLevel(params[0]) == params[1]) return SendClientMessage(playerid, -1, ".רמת האדמין של שחקן זה זהה");
		if(!params[1])
		{
		    if(DOF2_IsSet(BFile(playerid), "Days"))
			{
			    DOF2_Unset(BFile(playerid), "Days");
				DOF2_Unset(BFile(playerid), "Date");
			}
		    GetBLevel(params[0]) = 0;
			IsBLogged(params[0]) = false;
			IsBAdmin(params[0]) = false;
			return SendClientMessage(params[0], Pink, ".האדמין הוריד את דרגת האדמין שלך וכעת אתה שחקן רגיל");
		}
  		IsBLogged(params[0]) = false;
		pI[params[0]][ChangeLevel] = true;
		GetBLevel(params[0]) = params[1];
		return SendClientMessage(params[0], Yellow, "/ALogin האדמין שינה את רמת האדמין שלך ולכן תצטרך להתחבר שוב למערכת. - בכדי להתחבר למערכת הקש");
	}
	if(!params[1]) return SendClientMessage(playerid, -1, ".שחקן זה אינו אדמין");
	pI[params[0]][newAdmin] = true;
	IsBAdmin(params[0]) = true;
	GetBLevel(params[0]) = params[1];
	IsBLogged(params[0]) = false;
	Message(playerid, Aqua, "! לרמת אדמין %i %s העלאת את", params[1], GetName(params[0]));
	Message(params[0], Aqua, ".מזל טוב ! עלית לרמת אדמין %i", params[1]);
	return SendClientMessage(params[0], Aqua, "/ALogin בכדי להתחבר למערכת האדמינים הקש");
}

CMD:settempadmin(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return false;
	if(sscanf(params, "rii", params[0], params[1], params[2])) return SendClientMessage(playerid, -1, "/SetTempAdmin [Name/ID] [Level] [Days]");
	ConnectMessage(playerid, params[0]);
	if(IsBAdmin(params[0])) return SendClientMessage(playerid, -1, ".שחקן זה כבר אדמין");
	if(!params[1]) return Message(playerid, -1, "/SetTempAdmin [Name/ID] [Level (1 - %i)] [Days (1 - %i)]", MAX_LEVEL, MAX_DAYS);
	pI[params[0]][newAdmin] = true;
	IsBAdmin(params[0]) = true;
	GetBLevel(params[0]) = params[1];
	IsBLogged(params[0]) = false;
	new date[3];
    getdate(date[2], date[1], date[0]);
    format(g_String, 11, "%d.%d.%d", date[0], date[1], date[2]);
    DOF2_SetInt(BFile(params[0]), "Days", params[2]);
	DOF2_SetString(BFile(params[0]), "Date", g_String);
	DOF2_SaveFile();
	if(params[2] > 1)
	{
		Message(playerid, Aqua, "! לרמת אדמין %i ל %i ימים %s העלאת את", params[1], params[2], GetName(params[0]));
		Message(params[0], Aqua, ".מזל טוב ! עלית לרמת אדמין %i ל %i ימים", params[1]);
	}
	else if(params[2])
	{
		Message(playerid, Aqua, "! לרמת אדמין %i ליום אחד %s העלאת את", params[1], GetName(params[0]));
		Message(params[0], Aqua, ".מזל טוב ! עלית לרמת אדמין %i ליום אחד", params[1]);
	}
	return SendClientMessage(params[0], Aqua, "/ALogin בכדי להתחבר למערכת האדמינים הקש");
}

CMD:alogin(playerid, params[])
{
	if(!IsBAdmin(playerid)) return false;
	if(IsBLogged(playerid)) return SendClientMessage(playerid, -1, "! אתה כבר מחובר למערכת אדמינים");
	if(sscanf(params, "s[128]", params)) return SendClientMessage(playerid, -1, "/ALogin [password]");
	if(pI[playerid][newAdmin])
	{
 		pI[playerid][newAdmin] = false;
		IsBLogged(playerid) = true;
		strcpy(pI[playerid][Password], params, 128);
		return SendClientMessage(playerid, Yellow, "/Ah ברוך הבא למערכת האדמינים ! בכדי לקבל עזרה הקש");
	}
	else
	{
	    if(!strcmp(params, pI[playerid][Password], false))
	    {
			IsBLogged(playerid) = true;
			if(!pI[playerid][ChangeLevel])
				GetBLevel(playerid) = DOF2_GetInt(BFile(playerid), "Admin_Level");
		}
		else
		{
		    pI[playerid][Fail]++;
      		Message(playerid, Red, "[%i / 3] >> "white"! סיסמה שגויה", pI[playerid][Fail]);
		    if(pI[playerid][Fail] >= 3) return KickEx(playerid),
		    	SendClientMessage(playerid, -1, ".הקשת 3 פעמים סיסמה שגויה ולכן קיבלת בעיטה מן השרת");
			return true;
		}
	}
	DOF2_SetString(BFile(playerid), "LoggedIP", GetIP(playerid));
	return SendClientMessage(playerid, Aqua, ".התחברת למערכת אדמינים");
}

CMD:admins(playerid, params[]) return cmd_a(playerid, params);
CMD:a(playerid, params[])
{
	g_String[0] = EOS, sI[Admins] = 0;
	loop(i) if(IsBAdmin(i) && IsBLogged(i))
	{
	    sI[Admins]++;
	    format(g_String, sizeof g_String, "%s"red"%i. "blue"%s [id: %i | level: %i]\n", g_String, sI[Admins], GetName(i), i, GetBLevel(i));
	}
	if(!sI[Admins])
	    return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""red"Admins online:", ""white".אין אדמינים מחוברים", "יציאה", "");
	return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""green"Admins online:", g_String, "יציאה", "");
}

CMD:say(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "s[256]", params)) return SendClientMessage(playerid, -1, "/Say [text]");
	return Message(playerid, Red, "** Admin %s: "yellow"%s", GetName(playerid), params);
}

CMD:givemoney(playerid, params[]) return cmd_gm(playerid, params);
CMD:gm(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ri", params[0], params[1])) return SendClientMessage(playerid, -1, "/Gm [Name/ID] [Money]");
	ConnectMessage(playerid, params[0]);
	if(params[1] > 100000000 || params[1] < 100) return SendClientMessage(playerid, -1, "/Gm [playerid/name] [100 - 100,000,000]");
	GivePlayerMoney(params[0], params[1]);
	if(playerid != params[0])
	{
		Message(playerid, Green, ".$%s \"%s\" שלחת לשחקן", GetNum(params[1]), GetName(params[0]));
		return Message(params[0], Green, ".שלח לך $%s \"%s\" האדמין", GetNum(params[1]), GetName(playerid));
	}
	else return Message(playerid, Green, ".$%s הבאת לעצמך", GetNum(params[1]));
}

CMD:giveweapon(playerid, params[]) return cmd_gw(playerid, params);
CMD:gw(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "rii", params[0], params[1], params[2])) return SendClientMessage(playerid, -1, "/Gw [Name/ID] [Weapon ID] [Ammo]");
	ConnectMessage(playerid, params[0]);
	if(params[1] < 0 || params[1] > 46 || params[1] == 19 || params[1] == 20 || params[1] == 21) return SendClientMessage(playerid, -1, "/Gw [Name/ID] [Weapon ID (0 - 18 | 22 - 46)] [Ammo]");
	if(params[2] < MIN_AMMO) return Message(playerid, -1, "/Gw [Name/ID] [Weapon ID] [Ammo (Min: %i)]", MIN_AMMO);
	GivePlayerWeapon(params[0], params[1], params[2]);
	new weaponame[34];
	GetWeaponName(params[1], weaponame, sizeof weaponame);
	if(playerid != params[0])
	{
		Message(playerid, Pink, ".%s את הנשק \"%s\" הבאת לשחקן", weaponame, GetName(params[0]));
		return Message(params[0], Pink, ".%s הביא לך את הנשק \"%s\" האדמין", weaponame, GetName(playerid));
	}
	else return Message(playerid, Pink, ".%s הבאת לעצמך את הנשק", weaponame);
}

CMD:countdown(playerid, params[]) return cmd_cd(playerid, params);
CMD:cd(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ui", params[0], params[1])) return SendClientMessage(playerid, -1, "/Cd [ID (-1 = All)] [Number]");
	CountDown(params[0], params[1]);
	return Message(params[0], Yellow, "[%i] >> החל ספירה לאחור \"%s\" האדמין", params[1], GetName(playerid));
}

CMD:kcd(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sI[CDTimer]) KillTimer(sI[CDTimer]);
	loop(i) if(pI[i][pCDTimer]) KillTimer(pI[i][pCDTimer]);
	return SendClientMessage(playerid, Orange, ".האדמין עצר את הספירה היורדת");
}

CMD:goto(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 2) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0])) return SendClientMessage(playerid, -1, "/Goto [Name/ID]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    new Float:Pos[3];
	if(GetPlayerState(params[0]) == PLAYER_STATE_DRIVER)
		GetVehiclePos(GetPlayerVehicleID(params[0]), Pos[0], Pos[1], Pos[2]);
	else
		GetPlayerPos(params[0], Pos[0], Pos[1], Pos[2]);
	SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));
	SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]+1.0);
	Message(playerid, Aqua, ".\"%s\" השתגרת לשחקן", GetName(params[0]));
	return Message(params[0], Aqua, ".השתגר אלייך "red"\"%s\" "aqua"האדמין", GetName(playerid));
}

CMD:get(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0])) return SendClientMessage(playerid, -1, "/Get [Name/ID]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
    new Float:Pos[3];
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		GetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
	else
		GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	SetPlayerInterior(params[0], GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(params[0], GetPlayerVirtualWorld(playerid));
	SetPlayerPos(params[0], Pos[0], Pos[1], Pos[2]+1.0);
	Message(playerid, Aqua, ".אלייך \"%s\" שיגרת את השחקן", GetName(params[0]));
	return Message(params[0], Aqua, ".שיגר אותך אליו "red"\"%s\" "aqua"האדמין", GetName(playerid));
}

CMD:playertoplayer(playerid, params[]) return cmd_ptp(playerid, params);
CMD:ptp(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 4) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "rr", params[0], params[1])) return SendClientMessage(playerid, -1, "/Ptp [Name/ID] [Name/ID]");
    ConnectMessage(playerid, params[0]);
    ConnectMessage(playerid, params[1]);
    if(playerid == params[0] && playerid == params[1] || params[0] == params[1])
        return SendClientMessage(playerid, Red, "! פעולה שגויה");
    new Float:Pos[3];
	if(GetPlayerState(params[0]) == PLAYER_STATE_DRIVER)
		GetVehiclePos(GetPlayerVehicleID(params[0]), Pos[0], Pos[1], Pos[2]);
	else
		GetPlayerPos(params[0], Pos[0], Pos[1], Pos[2]);
	SetPlayerInterior(params[1], GetPlayerInterior(params[0]));
	SetPlayerVirtualWorld(params[1], GetPlayerVirtualWorld(params[0]));
	SetPlayerPos(params[1], Pos[0], Pos[1], Pos[2]+0.5);
	if(playerid != params[0] && playerid != params[1])
	{
		Message(playerid, Aqua, ".\"%s\" לשחקן \"%s\" שיגרת את השחקן", GetName(params[0]), GetName(params[1]));
		Message(params[1], Aqua, ".\"%s\" שיגר אותך לשחקן "red"\"%s\" "aqua"האדמין", GetName(params[0]), GetName(playerid));
		return Message(params[0], Aqua, ".אלייך \"%s\" שיגר את השחקן "red"\"%s\" "aqua"האדמין", GetName(params[1]), GetName(playerid));
	}
    if(playerid == params[0])
    {
    	Message(playerid, Aqua, ".אלייך \"%s\" שיגרת את השחקן", GetName(params[1]));
		return Message(params[1], Aqua, ".שיגר אותך אליו "red"\"%s\" "aqua"האדמין", GetName(playerid));
	}
	if(playerid == params[1])
	{
		Message(playerid, Aqua, ".\"%s\" השתגרת לשחקן", GetName(params[0]));
		return Message(params[0], Aqua, ".השתגר אלייך "red"\"%s\" "aqua"האדמין", GetName(playerid));
	}
	return true;
}

CMD:explode(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0])) return SendClientMessage(playerid, -1, "/Explode [Name/ID]");
    ConnectMessage(playerid, params[0]);
    if(GetBLevel(playerid) <= GetBLevel(params[0]) && playerid != params[0]) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
	new Float:Pos[3];
    GetPlayerPos(params[0], Pos[0], Pos[1], Pos[2]);
    CreateExplosion(Pos[0], Pos[1], Pos[2], 2, 10.0);
    if(playerid != params[0])
    {
    	Message(params[0], Orange, ".פיצץ אותך "red"\"%s\" "orange"האדמין", GetName(playerid));
		return Message(playerid, Orange, ".\"%s\" פוצצת את השחקן", GetName(params[0]));
	}
	else return SendClientMessage(playerid, Orange, ".פוצצת את עצמך");
}

CMD:mute(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ris[128]", params[0], params[1], params[2])) return SendClientMessage(playerid, -1, "/Mute [Name/ID] [Minutes] [Reason]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
    if(pI[params[0]][Muted]) return SendClientMessage(playerid, -1, ".שחקן זה כבר מושתק");
    if(params[1] < 1) return SendClientMessage(playerid, -1, "/Mute [Name/ID] [Minutes] [Reason] | מספר הדקות חייב להיות גדול מ 0");
    pI[params[0]][Muted] = true;
    strcpy(pI[params[0]][MuteReason], params[2], strlen(params[2])+1);
    Message(-1, Yellow, "\"%s\" has been muted by "red"\"%s\" "yellow"for %i minute(s). (Reason: %s)", GetName(params[0]), GetName(playerid), params[1], params[2]);
	return pI[params[0]][MutedTimer] = SetTimerEx("UnMute", params[1]*1000*60, false, "i", params[0]);
}

CMD:unmute(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0])) return SendClientMessage(playerid, -1, "/UnMute [Name/ID]");
    ConnectMessage(playerid, params[0]);
    if(!pI[params[0]][Muted]) return SendClientMessage(playerid, -1, ".שחקן זה אינו מושתק");
    KillTimer(pI[params[0]][MutedTimer]);
    pI[params[0]][Muted] = false;
    if(playerid != params[0])
    	return Message(-1, Yellow, "\"%s\" has been unmuted by "red"\"%s\""yellow".", GetName(params[0]), GetName(playerid));
    else
		return SendClientMessage(playerid, Yellow, ".הורדת לעצמך את המיוט");
}

CMD:muted(playerid, params[])
{
	g_String[0] = EOS, sI[Admins] = 0;
	loop(i) if(pI[i][Muted])
	{
	    sI[Admins]++;
	    format(g_String, sizeof g_String, "%s"red"%i. "blue"%s [id: %i | reason: %s]\n", g_String, sI[Admins], GetName(i), i, pI[i][MuteReason]);
	}
	if(!sI[Admins])
	    return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""red"Muted:", ""white".אין שחקנים מושתקים", "יציאה", "");
	return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""green"Muted:", g_String, "יציאה", "");
}

CMD:kick(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "rs[128]", params[0], params[1])) return SendClientMessage(playerid, -1, "/Kick [Name/ID] [Reason]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
    Message(-1, Yellow, "\"%s\" has been kicked by "red"\"%s\""yellow". (Reason: %s)", GetName(params[0]), GetName(playerid), params[1]);
	return KickEx(params[0]);
}

CMD:ka(playerid, params[]) return cmd_kickall(playerid, params);
CMD:kickall(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 6) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, -1, "/KickAll [Reason]");
	loop(i) if(GetBLevel(playerid) > GetBLevel(i) && i != playerid)
	{
		Message(-1, Red, "\"%s\" "yellow" kicked all players. (Reason: %s)", GetName(playerid), params[0]);
		return KickEx(i);
	}
	return true;
}

CMD:ban(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 5) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "rs[128]", params[0], params[1])) return SendClientMessage(playerid, -1, "/Ban [Name/ID] [Reason]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
    new date[3], time[3];
	getdate(date[2], date[1], date[0]), gettime(time[0], time[1], time[2]);
	format(BFile(params[0]), MAX_PLAYER_NAME+19, "BAdmin/Banned/%s.ini", GetName(params[0]));
	DOF2_CreateFile(BFile(params[0]));
	DOF2_SetString(BFile(params[0]), "Admin", GetName(playerid));
	DOF2_SetString(BFile(params[0]), "Reason", params[1]);
	format(g_String, 11, "%02d:%02d", time[0], time[1]);
	DOF2_SetString(BFile(params[0]), "Time", g_String);
	format(g_String, 11, "%02d.%02d.%02d", date[0], date[1], date[2]);
	DOF2_SetString(BFile(params[0]), "Date", g_String);
	DOF2_SaveFile();
	format(g_String, sizeof g_String, ""blue"Ban info:\nTime & Date: %s | %02d:%02d\nUnban days left: .הבאן לא ירד\n\n"red"Admin: "white"%s\n"red"Reason: "white"%s\n"red"Your IP: "white"%s", g_String, time[0], time[1], GetName(playerid), params[1], GetIP(params[0]));
	ShowPlayerDialog(params[0], DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""red"Banned !", g_String, "יציאה", "");
    Message(-1, Yellow, "\"%s\" has been banned by admin "red"\"%s\" "yellow". (Reason: %s)", GetName(params[0]), GetName(playerid), params[1]);
	return KickEx(params[0]);
}

CMD:tempban(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 6) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ris[128]", params[0], params[1], params[2])) return SendClientMessage(playerid, -1, "/Ban [Name/ID] [Days] [Reason]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
	if(params[1] < MIN_DAYS || params[1] > MAX_DAYS) return Message(playerid, -1, "/Ban [Name/ID] [Days (%i - %i)] [Reason]", MIN_DAYS, MAX_DAYS);
    new date[3], time[3];
	getdate(date[2], date[1], date[0]), gettime(time[0], time[1], time[2]);
	format(BFile(params[0]), MAX_PLAYER_NAME+19, "BAdmin/Banned/%s.ini", GetName(params[0]));
	DOF2_CreateFile(BFile(params[0]));
	DOF2_SetString(BFile(params[0]), "Admin", GetName(playerid));
	DOF2_SetString(BFile(params[0]), "Reason", params[2]);
	format(g_String, 11, "%02d:%02d", time[0], time[1]);
	DOF2_SetString(BFile(params[0]), "Time", g_String);
	format(g_String, 11, "%02d.%02d.%02d", date[0], date[1], date[2]);
	DOF2_SetString(BFile(params[0]), "Date", g_String);
	DOF2_SetInt(BFile(params[0]), "Days", params[1]);
	DOF2_SaveFile();
	format(g_String, sizeof g_String, ""blue"Ban info:\nTime & Date: %s | %02d:%02d\nUnban days left: %i\n\n"red"Admin: "white"%s\n"red"Reason: "white"%s\n"red"Your IP: "white"%s", g_String, time[0], time[1], params[1], GetName(playerid), params[2], GetIP(params[0]));
	ShowPlayerDialog(params[0], DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""red"Banned !", g_String, "יציאה", "");
    if(params[1] > 1)
		Message(-1, Yellow, "\"%s\" has been banned by admin "red"\"%s\" "yellow"for %i days. (Reason: %s)", GetName(params[0]), GetName(playerid), params[1], params[2]);
    else
		Message(-1, Yellow, "\"%s\" has been banned by admin "red"\"%s\" "yellow"for 1 day. (Reason: %s)", GetName(params[0]), GetName(playerid), params[2]);
	return KickEx(params[0]);
}

CMD:unban(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < MAX_LEVEL) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "s[24]", params)) return SendClientMessage(playerid, -1, "/UnBan [Name]");
	new pFile[MAX_PLAYER_NAME+19];
	format(pFile, sizeof pFile, "BAdmin/Banned/%s.ini", params);
	if(!DOF2_FileExists(pFile)) return SendClientMessage(playerid, -1, ".שחקן זה איננו בבאן");
	DOF2_RemoveFile(pFile);
	return Message(playerid, -1, ".את הבאן \"%s\" הורדת לשחקן", params);
}

CMD:spawnc(playerid, params[]) return cmd_spawnv(playerid, params);
CMD:spawnv(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 4) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
    if(isnull(params)) return SendClientMessage(playerid, -1, "/Spawnc [Vehicle name/model]");
    new id;
    if(!IsNumeric(params))
	{
		for(new i; i < sizeof VehicleName; i++) if(strfind(VehicleName[i], params, true) != -1)
	 	{
			id = i + 400;
			break;
		}
		if(!id) return SendClientMessage(playerid, -1, ".שם המכונית שגוי");
	}
	else
	{
		if(strval(params) < 400 || strval(params) > 611) return SendClientMessage(playerid, -1, "/Spawnc [Vehicle name/model (400 - 611)]");
		id = strval(params);
    }
    new Float:Pos[4];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, Pos[3]);
	DestroyVehicle(pI[playerid][AdminVehicle]);
	pI[playerid][AdminVehicle] = CreateVehicle(id, Pos[0], Pos[1], Pos[2]+1, Pos[3], -1, -1, -1);
	SetVehicleNumberPlate(pI[playerid][AdminVehicle], GetName(playerid));
	SetVehicleVirtualWorld(pI[playerid][AdminVehicle], GetPlayerVirtualWorld(playerid));
	PutPlayerInVehicle(playerid, pI[playerid][AdminVehicle], 0);
	return Message(playerid, Pink, "."purple"\"%s\" "pink"זימנת את הרכב", GetVehicleName(pI[playerid][AdminVehicle]));
}

CMD:nos(playerid, params[]) return cmd_nitro(playerid, params);
CMD:nitro(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0]))
	{
 		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "/Nitro [Name/ID]");
 		else
 		{
		 	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			return SendClientMessage(playerid, Orange, ".הוספת למכוניתך ניטרו");
		}
	}
	ConnectMessage(playerid, params[0]);
	if(!IsPlayerInAnyVehicle(params[0])) return SendClientMessage(playerid, -1, ".השחקן לא נמצא בשום רכב");
	AddVehicleComponent(GetPlayerVehicleID(params[0]), 1010);
	if(params[0] == playerid)
	    return SendClientMessage(playerid, Orange, ".הוספת למכוניתך ניטרו");
	Message(params[0], Orange, ".הוסיף ניטרו למכוניתך \"%s\" האדמין", GetName(playerid));
	return Message(playerid, Orange, ".ניטרו \"%s\" הוספת למכוניתו של", GetName(params[0]));
}

CMD:fix(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0]))
	{
 		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "/Fix [Name/ID]");
 		else
 		{
 		    SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
		 	RepairVehicle(GetPlayerVehicleID(playerid));
			return SendClientMessage(playerid, Orange, ".מכוניתך תוקנה");
		}
	}
	ConnectMessage(playerid, params[0]);
	if(!IsPlayerInAnyVehicle(params[0])) return SendClientMessage(playerid, -1, ".השחקן לא נמצא בשום רכב");
    SetVehicleHealth(GetPlayerVehicleID(params[0]), 1000.0);
   	RepairVehicle(GetPlayerVehicleID(params[0]));
   	if(playerid != params[0])
   	{
   		Message(playerid, Pink, ".\"%s\" תיקנת את מכוניתו של", GetName(params[0]));
		return Message(params[0], Pink, ".תיקן את רכבך \"%s\" האדמין", GetName(playerid));
	}
	else
	    return SendClientMessage(playerid, Orange, ".מכוניתך תוקנה");
}

CMD:flip(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0]))
	{
 		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "/Fix [Name/ID]");
 		else
 		{
			new Float:Pos[4];
		    GetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
		    GetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[3]);
		    SetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
		    SetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[3]);
			return SendClientMessage(playerid, -1, ".הפכת את רכבך");
		}
	}
	ConnectMessage(playerid, params[0]);
    if(!IsPlayerInAnyVehicle(params[0])) return SendClientMessage(playerid, -1, ".השחקן לא נמצא בשום רכב");
    new Float:Pos[4];
    GetVehiclePos(GetPlayerVehicleID(params[0]), Pos[0], Pos[1], Pos[2]);
    GetVehicleZAngle(GetPlayerVehicleID(params[0]), Pos[3]);
    SetVehiclePos(GetPlayerVehicleID(params[0]), Pos[0], Pos[1], Pos[2]);
    SetVehicleZAngle(GetPlayerVehicleID(params[0]), Pos[3]);
    if(playerid != params[0])
    {
    	Message(playerid, Blue, ".\"%s\" הפכת את מכוניתו של", GetName(params[0]));
		return Message(params[0], Blue, ".הפך את רכבך \"%s\" האדמין", GetName(playerid));
	}
	else
		return SendClientMessage(playerid, -1, ".הפכת את רכבך");
}

CMD:inv(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 5) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(!pI[playerid][Inv])
	{
	    pI[playerid][Inv] = true;
	    SetPlayerHealth(playerid, 0x7F800000);
	    SetPlayerColor(playerid, 0xFFFFFF00);
	    ShowNameTags(0);
	    return SendClientMessage(playerid, Aqua, ".נכנסת למצב אדמין בתפקיד");
	}
	else
	{
	    pI[playerid][Inv] = false;
	    SetPlayerHealth(playerid, 100.0);
	    SetPlayerColor(playerid, random(0xFFFFFF00));
	    ShowNameTags(1);
	    return SendClientMessage(playerid, Purple, ".יצאת ממצב אדמין בתפקיד");
	}
}

CMD:jail(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < 4) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "ris[128]", params[0], params[1], params[2])) return SendClientMessage(playerid, -1, "/Jail [Name/ID] [Minutes] [Reason]");
    ConnectMessage(playerid, params[0]);
    if(playerid == params[0]) return SendClientMessage(playerid, -1, ".אינך יכול לבצע פעולה זו על עצמך");
    if(GetBLevel(playerid) <= GetBLevel(params[0])) return SendClientMessage(playerid, Red, "! אינך יכול לבצע פעולות אדמין על אדמינים ברמה שלך / גבוהה משלך");
    if(pI[params[0]][Jailed]) return SendClientMessage(playerid, -1, ".שחקן זה כבר בכלא");
    if(params[1] < 1) return SendClientMessage(playerid, -1, "/Jail [Name/ID] [Minutes] [Reason] | מספר הדקות חייב להיות גדול מ 0");
	new rand = random(sizeof JailPositions);
    SetPlayerPos(params[0], JailPositions[rand][0], JailPositions[rand][1], JailPositions[rand][2]);
    switch(rand)
    {
        case 0, 1, 2: SetPlayerInterior(params[0], 3);
        case 3, 4, 5: SetPlayerInterior(params[0], 6);
    }
    pI[params[0]][Jailed] = true;
    strcpy(pI[params[0]][JailReason], params[2], strlen(params[2])+1);
    Message(-1, Yellow, "\"%s\" has been jailed by "red"\"%s\" "yellow"for %i minute(s). (Reason: %s)", GetName(params[0]), GetName(playerid), params[1], params[2]);
	return pI[params[0]][JailedTimer] = SetTimerEx("UnJail", params[1]*1000*60, false, "i", params[0]);
}

CMD:unjail(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < 6) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(sscanf(params, "r", params[0])) return SendClientMessage(playerid, -1, "/UnJail [Name/ID]");
    ConnectMessage(playerid, params[0]);
    if(!pI[params[0]][Jailed]) return SendClientMessage(playerid, -1, ".שחקן זה אינו בכלא");
    KillTimer(pI[params[0]][JailedTimer]);
    SpawnPlayer(params[0]);
    pI[params[0]][Jailed] = false;
    if(playerid != params[0])
    	return Message(-1, Yellow, "\"%s\" has been unjailed by "red"\"%s\""yellow".", GetName(params[0]), GetName(playerid));
    else
		return SendClientMessage(playerid, Yellow, ".הוצאת את עצמך מהכלא");
}

CMD:jailed(playerid, params[])
{
	g_String[0] = EOS, sI[Admins] = 0;
	loop(i) if(pI[i][Jailed])
	{
	    sI[Admins]++;
	    format(g_String, sizeof g_String, "%s"red"%i. "blue"%s [id: %i | reason: %s]\n", g_String, sI[Admins], GetName(i), i, pI[i][JailReason]);
	}
	if(!sI[Admins])
	    return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""red"Jailed:", ""white".אין שחקנים בכלא", "יציאה", "");
	return ShowPlayerDialog(playerid, DIALOG_MESSAGES, DIALOG_STYLE_MSGBOX, ""green"Jailed:", g_String, "יציאה", "");
}

CMD:god(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < MAX_LEVEL-1) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	if(!pI[playerid][God])
	{
	    pI[playerid][God] = true;
		SetPlayerHealth(playerid, 0x7F800000);
		GivePlayerWeapon(playerid, 38, 10000);
		return SendClientMessage(playerid, Pink, ".נכנסת למצב גודמוד");
	}
	else
	{
	    pI[playerid][God] = false;
		SetPlayerHealth(playerid, 100.0);
		return SendClientMessage(playerid, Pink, ".יצאת ממצב גודמוד");
	}
}

CMD:editmessages(playerid, params[])
{
    if(!IsBAdmin(playerid) || GetBLevel(playerid) < MAX_LEVEL-3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	return ShowPlayerDialog(playerid, DIALOG_EDIT_MESSAGES, DIALOG_STYLE_LIST, "עריכת הודעות", "עריכת לוח מודעות\nעריכת הודעות אוטומטיות", "המשך", "יציאה");
}
	
CMD:showmessages(playerid, params[])
{
	if(!IsBAdmin(playerid) || GetBLevel(playerid) < MAX_LEVEL-3) return false;
	if(IsBAdmin(playerid) && !IsBLogged(playerid)) return SendClientMessage(playerid, Red, "/ALogin אינך מחובר למערכת האדמינים. - בכדי להתחבר הקש");
	ServerMessages();
	return SendClientMessage(playerid, -1, ".הראת את לוח המודעות");
}

// =============================================================================

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(pI[playerid][Jailed]) return SendClientMessage(playerid, Red, ".אינך יכול לבצע פקודות שאתה בכלא"), false;
	return true;
}

public KickPlayer(playerid) return Kick(playerid);

public CountDown(playerid, number)
{
    if(playerid == -1 || playerid == INVALID_PLAYER_ID)
    {
        #pragma unused playerid
        loop(i) if(!pI[i][pCDTimer]) GameText(i, "~r~%i", 1100, 3, number);
        number--;
        KillTimer(sI[CDTimer]);
        sI[CDTimer] = SetTimerEx("CountDown", 950, false, "ii", -1, number);
        if(number <= -1)
		{
   			KillTimer(sI[CDTimer]);
			loop(i) if(!pI[i][pCDTimer]) GameTextForAll("~g~Go, go, go ~r~!", 2500, 3);
		}
    }
    else
	{
		GameText(playerid, "~r~%i", 1100, 3, number);
		number--;
		KillTimer(pI[playerid][pCDTimer]);
		pI[playerid][pCDTimer] = SetTimerEx("CountDown", 950, false, "ii", playerid, number);
		if(number <= -1)
		{
			KillTimer(pI[playerid][pCDTimer]);
			GameTextForPlayer(playerid, "~g~Go, go, go ~r~!", 2500, 3);
		}
	}
	return true;
}

public UnMute(playerid)
{
	pI[playerid][Muted] = false;
	return Message(-1, Yellow, "\"%s\" has been unmuted automatically by the server.", GetName(playerid));
}

public UnJail(playerid)
{
	SpawnPlayer(playerid);
	pI[playerid][Jailed] = false;
	return Message(-1, Yellow, "\"%s\" has been unjailed automatically by the server.", GetName(playerid));
}

public ServerMessages()
{
    SendClientMessageToAll(Aqua, "================= > לוח מודעות < =================");
    for(new i; i < 5; i++)
        SendClientMessageToAll(Aqua, Server_Message[i]);
	SendClientMessageToAll(Aqua, "==============================================");
	sI[showmessage]++;
	if(sI[showmessage] == 2)
	{
	    Message(-1, Pink, "[Server Message] >> "white"%s", Auto_Message[random(10)]);
	    sI[showmessage] = 0;
	}
}

// =============================================================================
#include <stock>
