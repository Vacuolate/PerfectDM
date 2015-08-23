#include <a_samp>
#include <sscanf2>
#include <foreach>
#include <Floats>
#include <y_va>

#define Message2 				SendClientMessage
#define Message2All             SendClientMessageToAll
#define loop(%0)				foreach (new %0 : Player)
#define GetName(%0)             InAct[%0][Name]

#define STARTTIME               15

#define MiniActive              1
#define WarActive               2
#define SWarActive              3
#define TWarActive              4
#define BoomActive              5
#define BazookaActive           6

//=== Dialog's
#define DIALOG_ACT              5000
#define DIALOG_STARTACT 		5001
#define DIALOG_STOPACT  		5002
#define DIALOG_REWARD        	5003

//=== Reward's
#define MiniAutoActReward       7000
#define WarAutoActReward       	7000
#define SWarAutoActReward       7000
#define TWarAutoActReward       7000
#define BoomAutoActReward       7000
#define BazookaAutoActReward    7000

//=== Colors
#define Aqua    			0x00FFFFFF
#define Red                 0xFF0000FF
#define Yellow             	0xFFFF00FF
#define Orange             	0xFF8800FF
#define Pink               	0xFF00FFFF
#define Blue               	0x0059FFFF
#define Green               0x00FF08FF
#define Purple              0x5100FFFF
//====================================
#define yellow              "{F6FF00}"
#define red                 "{FF0000}"
#define white               "{FFFFFF}"
#define pink                "{FF00FF}"
#define blue                "{0059FF}"
#define purple              "{5100FF}"
#define green               "{00FF08}"
#define orange				"{FF8800}"
#define aqua                "{00FFFF}"

//=== Team's
#define GroveTeam           1
#define BallasTeam          2
#define NoTeam              225

//=== News
enum InACT
{
	bool: ActIn,
   	TWarPlayerID,
   	Name[MAX_PLAYER_NAME]
}

enum act
{
	Players,
	Active,
	bool: Started,
	Timer,
	CD,
	Reward,
	num,
	RandomNum,
	GA,
	atime,
	GrovePlayers,
	BallasPlayers,
	ListItem
}

new
	String[330],
	Mini[21],
	War[21],
	Swar[21],
	Twar[21],
	Boom[21],
	Bazooka[21],
	InAct[MAX_PLAYERS][InACT],
	ActInfo[act],
	SWarVehicle[30]
	;

//=== Forwards
forward StartACT();
forward ACTStarted();
forward bool:IsPlayerWithVehicleInWater(playerid);
forward RandBoom();
forward IsPlayerInWater();
forward AutoAct();

public OnFilterScriptInit()
{
	SendRconCommand("loadfs ACTObjects");
	SetTimer("AutoAct", 60000*STARTTIME, true);
	ActInfo[ListItem] = -1;
	loop(i) PlayerConnect(i);
	print("\n\n==========================================");
	print("||= Act system by benel1 / PerfectQuar =||");
	print("==========================================\n\n");
	return true;
}

public OnFilterScriptExit() 		return SendRconCommand("unloadfs ACTObjects");
public OnPlayerConnect(playerid) 	return PlayerConnect(playerid);

public OnPlayerDisconnect(playerid, reason)
{
	if(InAct[playerid][ActIn])
	{
		ActInfo[Players]--;
		if(ActInfo[Players] && ActInfo[Started])
		{
		    KillTimer(ActInfo[Timer]);
			ActInfo[Players] = 0;
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[ListItem] = -1;
			if(ActInfo[Active] == MiniActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Mini המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
			else if(ActInfo[Active] == WarActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא War המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
			else if(ActInfo[Active] == SWarActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא SWar המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
			else if(ActInfo[Active] == TWarActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא TWar המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
			else if(ActInfo[Active] == BoomActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Boom המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
			else if(ActInfo[Active] == BazookaActive)
			{
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(playerid, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Bazooka המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		    return true;
		}
	}
	return true;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(InAct[playerid][ActIn] && ActInfo[Started] && ActInfo[Active] == SWarActive)
	{
		DestroyVehicle(GetPlayerVehicleID(playerid));
		SpawnPlayer(playerid);
	    InAct[playerid][ActIn] = false;
		ActInfo[Players]--;
		Message2(playerid, -1, ".יצאת מן הרכב ולכן הפסדת בפעילות, בהצלחה בפעם הבאה");
		if(ActInfo[Players])
		{
		    KillTimer(ActInfo[Timer]);
			ActInfo[Players] = 0;
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[ListItem] = -1;
			loop(i) if(InAct[i][ActIn])
			{
				InAct[i][ActIn] = false;
				SpawnPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerMoney(playerid, ActInfo[Reward]);
				Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא SWar המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
			}
		}
	}
	return true;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	ResetPlayerWeapons(playerid);
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(InAct[playerid][ActIn])
	{
		ActInfo[Players]--;
		if(ActInfo[Active] == MiniActive)
		{
		    if(InAct[playerid][ActIn])
			{
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
			if(ActInfo[Players] && ActInfo[Started])
   			{
				KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
    			loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Mini המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		}
		else if(ActInfo[Active] == WarActive)
		{
		    if(InAct[playerid][ActIn])
			{
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
		    if(ActInfo[Players] && ActInfo[Started])
   			{
  				KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא War המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		}
		else if(ActInfo[Active] == SWarActive)
		{
		    if(InAct[playerid][ActIn])
			{
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
		    if(ActInfo[Players] && ActInfo[Started])
   			{
			    KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא SWar המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		}
		else if(ActInfo[Active] == TWarActive)
		{
		    if(InAct[playerid][ActIn])
			{
			    if(InAct[playerid][TWarPlayerID] == GroveTeam) ActInfo[GrovePlayers]--;
			    else if(InAct[playerid][TWarPlayerID] == BallasTeam) ActInfo[BallasPlayers]--;
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
		    loop(i) if(ActInfo[BallasPlayers] > ActInfo[GrovePlayers] && !ActInfo[GrovePlayers] && InAct[i][ActIn])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
	   		 	SpawnPlayer(i);
				InAct[i][ActIn] = false;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				Message(-1, Purple, "! ניצחה בפעילות וכל שחקניה קיבלו כ %s$ Ballas הקבוצה", GetNum(ActInfo[Reward]));
				if(GetPlayerTeam(i) == BallasTeam) GivePlayerMoney(i, ActInfo[Reward]);
				SetPlayerTeam(i, NoTeam);
				SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
		    }
		    else if(ActInfo[BallasPlayers] < ActInfo[GrovePlayers] && !ActInfo[BallasPlayers] && InAct[i][ActIn])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
	   		 	SpawnPlayer(i);
				InAct[i][ActIn] = false;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				Message(-1, Green, "! ניצחה בפעילות וכל שחקניה קיבלו כ %s$ Grove הקבוצה", GetNum(ActInfo[Reward]));
				if(GetPlayerTeam(i) == GroveTeam) GivePlayerMoney(i, ActInfo[Reward]);
				SetPlayerTeam(i, NoTeam);
				SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
		    }
		    else if(!ActInfo[GrovePlayers] && !ActInfo[BallasPlayers] && InAct[i][ActIn])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
	   		 	SpawnPlayer(i);
				InAct[i][ActIn] = false;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				Message2All(Yellow, "! אף קבוצה אינה ניצחה בפעילות");
				SetPlayerTeam(i, NoTeam);
				SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
		    }
		}
		else if(ActInfo[Active] == BoomActive)
		{
		    if(InAct[playerid][ActIn])
			{
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
		    if(ActInfo[Players] && ActInfo[Started])
   			{
  				KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Boom המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		}
		else if(ActInfo[Active] == BazookaActive)
		{
		    if(InAct[playerid][ActIn])
			{
				InAct[playerid][ActIn] = false;
				//SpawnPlayer(playerid);
				ResetPlayerWeapons(playerid);
				Message2(playerid, -1, ".יצאת מן הפעילות");
			}
		    if(ActInfo[Players] && ActInfo[Started])
   			{
  				KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
			    loop(i) if(InAct[i][ActIn])
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					Message(-1, Yellow, "! וקיבל על כך %s$ %s הוא Bazooka המנצח בפעילות ה", GetNum(ActInfo[Reward]), GetName(i));
				}
			}
		}
	}
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_STARTACT && response)
    {
        switch(listitem)
        {
            case 0: OnPlayerCommandText(playerid, "/startmini");
            case 1: OnPlayerCommandText(playerid, "/startwar");
            case 2: OnPlayerCommandText(playerid, "/startswar");
            case 3: OnPlayerCommandText(playerid, "/starttwar");
            case 4: OnPlayerCommandText(playerid, "/startboom");
            case 5: OnPlayerCommandText(playerid, "/startbazooka");
        }
        //ActInfo[ListItem] = listitem;
        return true;
    }

    if(dialogid == DIALOG_STOPACT && response)
    {
        switch(listitem)
        {
            case 0: OnPlayerCommandText(playerid, "/stopmini");
            case 1: OnPlayerCommandText(playerid, "/stopwar");
            case 2: OnPlayerCommandText(playerid, "/stopswar");
            case 3: OnPlayerCommandText(playerid, "/stoptwar");
            case 4: OnPlayerCommandText(playerid, "/stopboom");
            case 5: OnPlayerCommandText(playerid, "/stopbazooka");
        }
        return true;
    }

    if(dialogid == DIALOG_REWARD && !response) return OnPlayerCommandText(playerid, "/startact");
    if(dialogid == DIALOG_REWARD && response)
    {
        if(!strlen(inputtext)) return SendClientMessage(playerid, Red, ".הכנס את סכום הכסף שהוזכה יקבל");
        if(ActInfo[ListItem] == 0) ActInfo[Active] = MiniActive;
		else if(ActInfo[ListItem] == 1) ActInfo[Active] = WarActive;
		else if(ActInfo[ListItem] == 2) ActInfo[Active] = SWarActive;
		else if(ActInfo[ListItem] == 3) ActInfo[Active] = TWarActive;
		else if(ActInfo[ListItem] == 4) ActInfo[Active] = BoomActive;
		else if(ActInfo[ListItem] == 5) ActInfo[Active] = BazookaActive;

		ActInfo[RandomNum] = random(80);

        if(ActInfo[Active] == MiniActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/startmini");
			Message2All(Orange, "------------- Mini -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Mini %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}

		else if(ActInfo[Active] == WarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/startwar");
			Message2All(Orange, "------------- War -------------");
			Message(INVALID_PLAYER_ID, Orange, "/War %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}

		else if(ActInfo[Active] == SWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/startswar");
			Message2All(Orange, "------------- SWar -------------");
			Message(INVALID_PLAYER_ID, Orange, "/SWar %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
			LoadSWarVehicles();
		}

        else if(ActInfo[Active] == TWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/starttwar");
			Message2All(Orange, "------------- TWar -------------");
			Message(INVALID_PLAYER_ID, Orange, "/TWar %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}

		else if(ActInfo[Active] == BoomActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/startboom");
			Message2All(Orange, "------------- Boom -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Boom %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}

		else if(ActInfo[Active] == BazookaActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return OnPlayerCommandText(playerid, "/startbazooka");
			Message2All(Orange, "------------- Bazooka -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Bazooka %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}

		if(ActInfo[Active] != 0)
		{
			KillTimer(ActInfo[Timer]);
		    ActInfo[GA] = playerid;
			ActInfo[atime] = gettime();
			ActInfo[Players] = 0;
			ActInfo[Timer] = SetTimer("StartACT", 1000, true);
			ActInfo[CD] = 30;
		}
        return true;
    }
	return true;
}

public StartACT()
{
	if(ActInfo[Active] == MiniActive)
	{
		if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/Mini נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    	if(!ActInfo[CD])
    	{
    	    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
			ActInfo[CD] = 11;
			new rand;
			loop(i) if(InAct[i][ActIn])
			{
			    rand = random(sizeof MiniSpawns);
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 10);
				SetPlayerPos(i, MiniSpawns[rand][0], MiniSpawns[rand][1], MiniSpawns[rand][2]);
				SetPlayerFacingAngle(i, MiniSpawns[rand][3]);
				SetCameraBehindPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerWeapon(i, 38, 9000);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
 		else
    	{
        	GameText(-1, "~y~[] ~r~/Mini %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
    	}
	}

	else if(ActInfo[Active] == WarActive)
	{
		if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/War נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    	if(!ActInfo[CD])
    	{
    	    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
        	ActInfo[CD] = 11;
			new rand;
			loop(i) if(InAct[i][ActIn])
			{
			    rand = random(sizeof WarSpawns);
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 10);
				SetPlayerVirtualWorld(i, 10);
				SetPlayerPos(i, WarSpawns[rand][0], WarSpawns[rand][1], WarSpawns[rand][2]);
				SetPlayerFacingAngle(i, WarSpawns[rand][3]);
				SetCameraBehindPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerWeapon(i, random(33-25)+25, 9000);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
 		else
    	{
        	GameText(-1, "~y~[] ~r~/War %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
    	}
	}

	else if(ActInfo[Active] == SWarActive)
	{
	    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/SWar נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
		if(!ActInfo[CD])
		{
		    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
	        ActInfo[CD] = 11;
			loop(i) if(InAct[i][ActIn])
			{
				SetPlayerVirtualWorld(i, 10);
				SetVehicleVirtualWorld(SWarVehicle[i], 10);
				PutPlayerInVehicle(i, SWarVehicle[i], 0);
				Message(i, -1, "VirtualWorld: %d", GetVehicleVirtualWorld(i));
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 0);
				SetCameraBehindPlayer(i);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
	 	else
	    {
	        GameText(-1, "~y~[] ~r~/SWar %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
	    }
	}

	else if(ActInfo[Active] == TWarActive)
	{
	    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/TWar נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    	if(!ActInfo[CD])
    	{
    	    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
        	ActInfo[CD] = 11;
        	new rand, rand2;
			loop(i) if(InAct[i][ActIn])
			{
			    rand = random(sizeof GrovePos), rand2 = random(sizeof BallasPos);
			    SetPlayerTeam(i, InAct[i][TWarPlayerID]);
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 10);
				SetPlayerVirtualWorld(i, 10);
				if(GetPlayerTeam(i) == GroveTeam)
				{
				    SetPlayerColor(i, Green);
				    SetPlayerSkin(i, random(107-105)+105);
					SetPlayerPos(i, GrovePos[rand][0], GrovePos[rand][1], GrovePos[rand][2]);
					SetPlayerFacingAngle(i, GrovePos[rand][3]);
				}
				if(GetPlayerTeam(i) == BallasTeam)
				{
				    SetPlayerColor(i, Purple);
				    SetPlayerSkin(i, random(104-102)+102);
				    SetPlayerPos(i, BallasPos[rand2][0], BallasPos[rand2][1], BallasPos[rand2][2]);
					SetPlayerFacingAngle(i, BallasPos[rand2][3]);
				}
				SetCameraBehindPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerWeapon(i, random(33-25)+25, 9000);
				GivePlayerWeapon(i, random(33-25)+25, 9000);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
 		else
    	{
        	GameText(-1, "~y~[] ~r~/TWar %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
    	}
	}

	else if(ActInfo[Active] == BoomActive)
	{
	    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/Boom נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    	if(!ActInfo[CD])
    	{
    	    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
			ActInfo[CD] = 11;
			new rand;
			loop(i) if(InAct[i][ActIn])
			{
			    rand = random(sizeof BoomSpawns);
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 10);
				SetPlayerPos(i, BoomSpawns[rand][0], BoomSpawns[rand][1], BoomSpawns[rand][2]);
				SetPlayerFacingAngle(i, BoomSpawns[rand][3]);
				SetCameraBehindPlayer(i);
				ResetPlayerWeapons(i);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
 		else
    	{
        	GameText(-1, "~y~[] ~r~/Boom %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
    	}
	}

	else if(ActInfo[Active] == BazookaActive)
	{
	    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) Message2All(Pink, "/Bazooka נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    	if(!ActInfo[CD])
    	{
    	    KillTimer(ActInfo[Timer]);
		    if(ActInfo[Players] <= 1)
			{
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[Players] = 0;
				loop(i) InAct[i][ActIn] = false;
				Message2All(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
				return true;
			}
			ActInfo[Started] = true;
			ActInfo[CD] = 11;
			new rand;
			loop(i) if(InAct[i][ActIn])
			{
			    rand = random(sizeof BazookaSpawns);
				SetPlayerHealth(i, 100);
				SetPlayerArmour(i, 0.0);
				SetPlayerInterior(i, 15);
				SetPlayerVirtualWorld(i, 10);
				SetPlayerPos(i, BazookaSpawns[rand][0], BazookaSpawns[rand][1], BazookaSpawns[rand][2]);
				SetPlayerFacingAngle(i, BazookaSpawns[rand][3]);
				SetCameraBehindPlayer(i);
				GivePlayerWeapon(i, 35, 850);
				TogglePlayerControllable(i, false);
			}
			ActInfo[Timer] = SetTimer("ACTStarted", 1000, true);
		}
 		else
    	{
        	GameText(-1, "~y~[] ~r~/Bazooka %d: ~b~%d~y~[]", 1000, 4, ActInfo[RandomNum], ActInfo[CD]);
			if(ActInfo[Players] == 30)
			{
				Message2All(Red, ".כל המקומות בפעילות נתפסו");
				ActInfo[Players] = 31;
			}
    	}
	}
	ActInfo[CD]--;
	return true;
}

public ACTStarted()
{
	if(ActInfo[Started])
	{
		if(ActInfo[CD] <= 0)
	    {
	    	KillTimer(ActInfo[Timer]);
			loop(i) if(InAct[i][ActIn])  TogglePlayerControllable(i, true), GameTextForPlayer(i, "Good Luck !", 2000, 3);
			if(ActInfo[Active] == BoomActive) ActInfo[Timer] = SetTimer("RandBoom", 1000, true);
			else if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 1000, false);
		}
		else loop(i) if(InAct[i][ActIn])
		{
			GameText(i, "~r~%d", 1000, 4, ActInfo[CD]);
			if(ActInfo[Active] == SWarActive && ActInfo[CD] == 5)
			{
			    SetVehicleToRespawn(SWarVehicle[i]);
				PutPlayerInVehicle(i, SWarVehicle[i], 0);
			}
		}
	}
	ActInfo[CD]--;
	return true;
}

public RandBoom()
{
    new rand = random(sizeof RandomBoom);
    for(new i; i < 10; i++) CreateExplosion(RandomBoom[rand][0], RandomBoom[rand][1], RandomBoom[rand][2], 2, 3);
	return true;
}

public IsPlayerInWater()
{
	loop(i) if(IsPlayerWithVehicleInWater(i))
	{
	    DestroyVehicle(GetPlayerVehicleID(i));
    	//InAct[i][ActIn] = false;
		//ActInfo[Players]--;
		SetPlayerHealth(i, 0.0);
		Message2(i, -1, ".נפלת למים אם הרכב ולכן הפסדת בפעילות, בהצלחה בפעמים הבאות");
  	}
  	if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 1000, false);
	return true;
}

public AutoAct()
{
    if(ActInfo[Active] != 0) return print("Act Active ..");
	switch(random(6))
	{
	    case 0:
	    {
	        ActInfo[Reward] = MiniAutoActReward;
			ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = MiniActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- Mini -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Mini %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}
	    case 1:
	    {
	        ActInfo[Reward] = WarAutoActReward;
			ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = WarActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- War -------------");
			Message(INVALID_PLAYER_ID, Orange, "/War %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}
	    case 2:
	    {
	        ActInfo[Reward] = SWarAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = SWarActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- SWar -------------");
			Message(INVALID_PLAYER_ID, Orange, "/SWar %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
			LoadSWarVehicles();
		}
	    case 3:
	    {
	        ActInfo[Reward] = TWarAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = TWarActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- TWar -------------");
			Message(INVALID_PLAYER_ID, Orange, "/TWar %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}
	    case 4:
	    {
	        ActInfo[Reward] = BoomAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = BoomActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- Boom -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Boom %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}
		case 5:
		{
		    ActInfo[Reward] = BazookaAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = BazookaActive;
			ActInfo[Players] = 0;
			Message2All(Orange, "------------- Bazooka -------------");
			Message(INVALID_PLAYER_ID, Orange, "/Bazooka %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
			Message(INVALID_PLAYER_ID, Orange, "! פרס למנצח: %s$", GetNum(ActInfo[Reward]));
			Message2All(Red, "! מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
			Message2All(Orange, "----------------------------------");
		}
	}
	ActInfo[Timer] = SetTimer("StartACT", 1000, true);
	ActInfo[CD] = 30;
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[128], idx;
	cmd = strtok(cmdtext, idx);

    if(InAct[playerid][ActIn] && (strcmp("/twarplayers", cmdtext, true) || strcmp("/act", cmdtext, true) || IsPlayerAdmin(playerid) && strcmp("/stopact", cmdtext, true)))
		return Message2(playerid, Red, ".אינך יכול לבצע פקודות כאשר אתה בפעילות");

	if(!strcmp(cmdtext, "/act", true))
	{
		new time2 = gettime()-ActInfo[atime], hour, minute, second;
		second = time2 % 60;
		time2 /= 60;
		minute = time2 % 60;
		time2 /= 60;
		hour = time2 % 24;

		if(ActInfo[Active] == MiniActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Mini הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == MiniActive)
		{
			format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Mini הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}

		if(ActInfo[Active] == WarActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,War הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == WarActive)
		{
			format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,War הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}

		if(ActInfo[Active] == SWarActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,SWar הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == SWarActive)
		{
			format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,SWar הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}

		if(ActInfo[Active] == TWarActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,TWar הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == TWarActive)
		{
			format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,TWar הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}

	    if(ActInfo[Active] == BoomActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Boom הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == BoomActive)
		{
			format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Boom הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}

		if(ActInfo[Active] == BazookaActive && ActInfo[GA] == -1)
		{
			format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Bazooka הפעילות", hour, minute, second);
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		else if(ActInfo[Active] == BazookaActive)
		{
			format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Bazooka הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	        ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
	        return true;
		}
		ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", ".אין פעילות כרגע", "אישור", "");
		return true;
	}

	if(!strcmp(cmdtext, "/startact", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		GetActStatus(Mini, War, Swar, Twar, Boom, Bazooka);
		format(String, sizeof String, "Minigun [/StartMini] - %s\nWar [/StartWar] - %s\nSultan Wars [/StartSWar] - %s\nTeam War [/StartTWar] - %s\nBoom [/StartBoom] - %s\nBazooka [/StartBazooka] - %s", Mini, War, Swar, Twar, Boom, Bazooka);
		ShowPlayerDialog(playerid, DIALOG_STARTACT, DIALOG_STYLE_LIST, "פעילויות", String, "הפעל", "ביטול");
		return true;
	}

	if(!strcmp(cmdtext, "/stopact", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		GetActStatus(Mini, War, Swar, Twar, Boom, Bazooka);
		format(String, sizeof String, "Minigun [/StopMini] - %s\nWar [/StopWar] - %s\nSultan Wars [/StopSWar] - %s\nTeam War [/StopTWar] - %s\nBoom [/StopBoom] - %s\nBazooka [/StopBazooka] - %s", Mini, War, Swar, Twar, Boom, Bazooka);
		ShowPlayerDialog(playerid, DIALOG_STOPACT, DIALOG_STYLE_LIST, "פעילויות", String, "עצור", "ביטול");
		return true;
	}

	//============================= [ Minigun ] ====================================
	if(!strcmp(cmdtext, "/startmini", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 0;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Minigun", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stopmini", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != MiniActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".Mini ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/mini", true))
	{
		if(ActInfo[Active] != MiniActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
      	new number = strval(cmd);
       	if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/Mini %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		return true;
	}

	//================================= [ War ] ====================================
	if(!strcmp(cmdtext, "/startwar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 1;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "War", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stopwar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != WarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".War ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/war", true))
	{
		if(ActInfo[Active] != WarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
      	new number = strval(cmd);
       	if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/War %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		return true;
	}

	//============================ [ Sultan Wars ] =================================
	if(!strcmp(cmdtext, "/startswar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 2;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Sultan Wars", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stopswar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != SWarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".Sultan Wars ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/swar", true))
	{
		if(ActInfo[Active] != SWarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
      	new number = strval(cmd);
       	if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/SWar %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		return true;
	}

	//============================ [ Team War ] ====================================
	if(!strcmp(cmdtext, "/starttwar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 3;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Team War", ".אנא הקש את סכום הכסף שהזוכים יקבלו", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stoptwar", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != TWarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".Team War ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/twar", true))
	{
		if(ActInfo[Active] != TWarActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
      	new number = strval(cmd);
       	if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/TWar %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		TWarPlayer(playerid);
		Message(playerid, -1, "%s", InAct[playerid][TWarPlayerID] == GroveTeam ? (""green"Grove: קבוצה") : (""purple"Ballas: קבוצה"));
		return true;
	}

	if(!strcmp(cmdtext, "/twarplayers", true))
	{
	    if(ActInfo[Active] != TWarActive) return Message2(playerid, -1, ".הפעילות אינה פועלת כרגע");
	    if(!ActInfo[Started]) return Message2(playerid, -1, ".הפעילות אינה החלה");
	    String = "";
		loop(i) if(InAct[i][ActIn])
	    	format(String, sizeof String, ""white"%s\n• %s | %s", String, GetName(i), (GetPlayerTeam(i)) ? (""green"Grove") : (""purple"Ballas"));
	    ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, ""green"Team "red"War "white"Players", String, "אישור", "");
		return true;
	}

	//============================== [ Boom ] ======================================
	if(!strcmp(cmdtext, "/startboom", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 4;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Boom", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stopboom", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != BoomActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".Boom ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/boom", true))
	{
		if(ActInfo[Active] != BoomActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
  		new number = strval(cmd);
   		if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/Boom %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		return true;
	}

	//============================= [ Bazooka ] ====================================
	if(!strcmp(cmdtext, "/startbazooka", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
		if(ActInfo[Active] != 0) return Message2(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
		ActInfo[ListItem] = 5;
		ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Bazooka", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
		return true;
	}

	if(!strcmp(cmdtext, "/stopbazooka", true))
	{
		if(!IsPlayerAdmin(playerid)) return false;
	    if(ActInfo[Active] != BazookaActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
	    KillTimer(ActInfo[Timer]);
		ActInfo[Players] = 0;
		ActInfo[Active] = 0;
		ActInfo[ListItem] = -1;
	    loop(i) if(InAct[i][ActIn])
		{
			if(ActInfo[Started])
			{
			    TogglePlayerControllable(i, true);
				SpawnPlayer(i);
			}
			InAct[i][ActIn] = false;
		}
		ActInfo[Started] = false;
		Message(INVALID_PLAYER_ID, Red, ".Bazooka ביטל את פעילות ה \"%s\" האדמין", GetName(playerid));
		return true;
	}

	if(!strcmp(cmd, "/bazooka", true))
	{
		if(ActInfo[Active] != BazookaActive) return Message2(playerid, Red, ".הפעילות אינה פועלת כרגע");
		if(ActInfo[Started]) return Message2(playerid, -1, ".הפעילות כבר החלה");
		if(ActInfo[Players] >= 30) return Message2(playerid, Red, ".כל המקומות נתפסו");
		if(InAct[playerid][ActIn]) return  Message2(playerid, Red, ".הצטרפת כבר לפעילות");
		cmd = strtok(cmdtext, idx);
      	new number = strval(cmd);
       	if(!strlen(cmd) || number != ActInfo[RandomNum]) return Message(playerid, Red, "/Bazooka %d", ActInfo[RandomNum]);
		InAct[playerid][ActIn] = true;
		ActInfo[Players]++;
		Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
		return true;
	}
	return false;
}

PlayerConnect(playerid)
{
    GetPlayerName(playerid, GetName(playerid), MAX_PLAYER_NAME);
	InAct[playerid][ActIn] = false;
	return true;
}

GetActStatus(mini[21], war[21], swar[21], twar[21], boom[21], bazooka[21])
{
	if(ActInfo[Active] == MiniActive) mini = ""green"פועל"white"";
	else if(ActInfo[Active] != MiniActive) mini = ""red"כבוי"white"";

	if(ActInfo[Active] == WarActive) war = ""green"פועל"white"";
	else if(ActInfo[Active] != WarActive) war = ""red"כבוי"white"";

	if(ActInfo[Active] == SWarActive) swar = ""green"פועל"white"";
	else if(ActInfo[Active] != SWarActive) swar = ""red"כבוי"white"";

	if(ActInfo[Active] == TWarActive) twar = ""green"פועל"white"";
	else if(ActInfo[Active] != TWarActive) twar = ""red"כבוי"white"";

	if(ActInfo[Active] == BoomActive) boom = ""green"פועל"white"";
	else if(ActInfo[Active] != BoomActive) boom = ""red"כבוי"white"";

	if(ActInfo[Active] == BazookaActive) bazooka = ""green"פועל"white"";
	else if(ActInfo[Active] != BazookaActive) bazooka = ""red"כבוי"white"";
}

TWarPlayer(playerid)
{
	if(ActInfo[Players] == 1)  return 	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 2)  return 	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 3)  return   ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 4)  return   ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 5)  return   ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 6)  return   ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 7)  return   ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 8)  return   ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 9)  return   ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 10) return   ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 11) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 12) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 13) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 14) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 15) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 16) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 17) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 18) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 19) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 20) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 21) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 22) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 23) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 24) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 25) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 26) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 27) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 28) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	if(ActInfo[Players] == 29) return  	ActInfo[GrovePlayers]++, 	InAct[playerid][TWarPlayerID] = 	GroveTeam;
	if(ActInfo[Players] == 30) return  	ActInfo[BallasPlayers]++, 	InAct[playerid][TWarPlayerID] = 	BallasTeam;
	return true;
}

stock Message(playerid, color, const message[], va_args<>)
{
	va_format(String, sizeof String, message, va_start<3>);
	if(playerid == -1 || playerid == INVALID_PLAYER_ID)
	{
	    #pragma unused playerid
	    SendClientMessageToAll(color, String);
	} else SendClientMessage(playerid, color, String);
	return true;
}

stock GameText(playerid, const message[], time, style, va_args<>)
{
	va_format(String, sizeof String, message, va_start<4>);
	if(playerid == -1 || playerid == INVALID_PLAYER_ID)
	{
	    #pragma unused playerid
	    GameTextForAll(String, time, style);
	} else GameTextForPlayer(playerid, String, time, style);
	return true;
}

stock LoadSWarVehicles()
{
	for(new i; i < 30; i++) DestroyVehicle(SWarVehicle[i]);
	SWarVehicle[0] = CreateVehicle(560, 1200.2151,-4385.0898,2.2056,359.9037, -1, -1, 999);
	SWarVehicle[1] = CreateVehicle(560, 1205.3563,-4385.3940,2.2051,180.1475, -1, -1, 999);
	SWarVehicle[2] = CreateVehicle(560, 1199.9310,-4429.0483,2.2052,359.1353, -1, -1, 999);
	SWarVehicle[3] = CreateVehicle(560, 1200.0554,-4468.7266,2.2046,178.5856, -1, -1, 999);
	SWarVehicle[4] = CreateVehicle(560, 1226.4907,-4476.5586,2.2172,88.5408, -1, -1, 999);
	SWarVehicle[5] = CreateVehicle(560, 1226.7183,-4515.9463,2.2016,90.1949, -1, -1, 999);
	SWarVehicle[6] = CreateVehicle(560, 1206.1499,-4499.9517,2.1986,357.0011, -1, -1, 999);
	SWarVehicle[7] = CreateVehicle(560, 1186.5161,-4499.0947,2.1991,180.2257, -1, -1, 999);
	SWarVehicle[8] = CreateVehicle(560, 1131.6272,-4498.0796,2.2029,227.3354, -1, -1, 999);
	SWarVehicle[9] = CreateVehicle(560, 1086.9137,-4501.3091,2.1887,312.2499, -1, -1, 999);
	SWarVehicle[10] = CreateVehicle(560, 1072.6195,-4466.0493,2.2051,359.6435, -1, -1, 999);
	SWarVehicle[11] = CreateVehicle(560, 1088.4100,-4432.2168,2.2055,269.1436, -1, -1, 999);
	SWarVehicle[12] = CreateVehicle(560, 1052.8190,-4421.1899,4.0696,268.8188, -1, -1, 999);
	SWarVehicle[13] = CreateVehicle(560, 1066.5084,-4408.1904,4.0686,180.6585, -1, -1, 999);
	SWarVehicle[14] = CreateVehicle(560, 1044.5258,-4376.5137,4.0706,90.1861, -1, -1, 999);
	SWarVehicle[15] = CreateVehicle(560, 1016.1380,-4340.6909,4.0786,269.3850, -1, -1, 999);
	SWarVehicle[16] = CreateVehicle(560, 1102.3306,-4335.6860,4.0703,269.6061, -1, -1, 999);
	SWarVehicle[17] = CreateVehicle(560, 1165.1935,-4355.2344,2.2005,179.8270, -1, -1, 999);
	SWarVehicle[18] = CreateVehicle(560, 1165.2235,-4325.2930,2.2055,90.1414, -1, -1, 999);
	SWarVehicle[19] = CreateVehicle(560, 1180.0328,-4309.1846,2.2006,270.5394, -1, -1, 999);
	SWarVehicle[20] = CreateVehicle(560, 1200.1256,-4285.6816,2.2121,179.6818, -1, -1, 999);
	SWarVehicle[21] = CreateVehicle(560, 1231.8606,-4312.0293,2.2006,89.6068, -1, -1, 999);
	SWarVehicle[22] = CreateVehicle(560, 1237.0814,-4345.5913,2.2056,359.3796, -1, -1, 999);
	SWarVehicle[23] = CreateVehicle(560, 1230.9258,-4351.9375,2.2006,88.1337, -1, -1, 999);
	SWarVehicle[24] = CreateVehicle(560, 1165.7096,-4284.8403,2.2056,267.6369, -1, -1, 999);
	SWarVehicle[25] = CreateVehicle(560, 1159.1910,-4279.6479,2.2051,89.4387, -1, -1, 999);
	SWarVehicle[26] = CreateVehicle(560, 1149.3004,-4297.5742,2.2056,269.9674, -1, -1, 999);
	SWarVehicle[27] = CreateVehicle(560, 1125.0808,-4279.5923,2.2051,269.0401, -1, -1, 999);
	SWarVehicle[28] = CreateVehicle(560, 1132.6385,-4258.2817,2.2055,180.1093, -1, -1, 999);
	SWarVehicle[29] = CreateVehicle(560, 1072.5242,-4264.0596,4.0695,89.3632, -1, -1, 999);
	return true;
}

stock bool:IsPlayerWithVehicleInWater(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return false;
    new Float:z;
    GetVehiclePos(GetPlayerVehicleID(playerid), z, z, z);
    return (z <= 0)?true:false;
}

stock GetNum(number)
{
	new idx = 3, ret[128], size;
	valstr(ret, number);
	size = strlen(ret);
	while(idx < size)
	{
		strins(ret, ",", size-idx);
		idx += 3;
	}
	return ret;
}

stock rgba2hex(r, g, b, a) return (r*16777216) + (g*65536) + (b*256) + a;

stock strtok(str[], &index, array[20] = ' ', dilimiter[2] = ' ') // _BigMan_ קרדיט ל
{
    array = "";
    strmid(array, str[index], 0, 20);
    new pos = strfind(array, dilimiter, false);
    if(pos != -1)
        {
        array[pos] = EOS;
        index += pos;
    }
    index++;
    return array;
}

//=== Act על הזמנים של ה make_belive קרדיט ל
