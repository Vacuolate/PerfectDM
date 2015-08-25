#include <a_samp>
#include <sscanf2>
#include <Spawns>

#define loop(%0)				for(new %0, lastid = GetPlayerPoolSize() + 1; %0 < lastid; %0++) if(IsPlayerConnected(%0))
#define GetName(%0)             InAct[%0][Name]
									
#define dcmd(%1,%2,%3) 			if(!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#define STARTTIME               15
#define IN_ACT_START_TIME       5

#define MiniActive              1
#define WarActive               2
#define SWarActive              3
#define TWarActive              4
#define BoomActive              5
#define BazookaActive           6
#define FlameActive				7
#define ChainActive             8

//=== Dialog's
#define DIALOG_ACT              5000
#define DIALOG_STARTACT 		5001
#define DIALOG_REWARD        	5002

//=== Reward's
#define MiniAutoActReward       7000
#define WarAutoActReward       	7000
#define SWarAutoActReward       7000
#define TWarAutoActReward       7000
#define BoomAutoActReward       7000
#define BazookaAutoActReward    7000
#define FlameAutoActReward		7000
#define ChainAutoActReward		7000

//=== Colors
#define Aqua    				0x00FFFFFF
#define Yellow             		0xFFFF00FF
#define Orange             		0xFF8800FF
#define Pink               		0xFF00FFFF
#define Blue               		0x0059FFFF
#define Green               	0x00FF08FF
#define Purple              	0x5100FFFF
#define Red                 	0xFF0000FF
//====================================
#define yellow              	"{F6FF00}"
#define red                 	"{FF0000}"
#define white               	"{FFFFFF}"
#define pink                	"{FF00FF}"
#define blue                	"{0059FF}"
#define purple              	"{5100FF}"
#define green               	"{00FF08}"
#define orange					"{FF8800}"
#define aqua                	"{00FFFF}"
#define red                 	"{FF0000}"

//=== Team's
#define GroveTeam           	1
#define BallasTeam          	2

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
	Mini[24],
	War[24],
	Swar[24],
	Twar[24],
	Boom[24],
	Bazooka[24],
	Flame[24],
	Chain[24],
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
	SetTimer("AutoAct", 60000*STARTTIME, 1);
	loop(i) PlayerConnect(i);
	print("\n\n==========================================");
	print("||= Act system by benel1 / PerfectQuar =||");
	print("==========================================\n\n");
	return 1;
}

public OnFilterScriptExit() 		return SendRconCommand("unloadfs ACTObjects");
public OnPlayerConnect(playerid) 	return PlayerConnect(playerid);

public OnPlayerDisconnect(playerid, reason)
{
	if(InAct[playerid][ActIn])
	{
	    ActInfo[Players]--;
	    if(ActInfo[Active] == TWarActive)
		{
		    if(GetPlayerTeam(playerid) == BallasTeam) ActInfo[BallasPlayers]--;
            if(GetPlayerTeam(playerid) == GroveTeam) ActInfo[GrovePlayers]--;
			if(ActInfo[GrovePlayers] >= 1 && !ActInfo[BallasPlayers])
			{
			    KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = 0;
				loop(i) if(InAct[i][ActIn] && GetPlayerTeam(i) == GroveTeam)
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				Message(-1, Green, "!$%s ניצחה בפעילות וכל שחקניה קיבלו על כך Grove הקבוצה", GetNum(ActInfo[Reward]));
			}
			if(ActInfo[BallasPlayers] >= 1 && !ActInfo[GrovePlayers])
			{
			    KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = 0;
				loop(i) if(InAct[i][ActIn] && GetPlayerTeam(i) == BallasTeam)
				{
					InAct[i][ActIn] = false;
					SpawnPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerMoney(i, ActInfo[Reward]);
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				Message(-1, Purple, "!"green"$%s "purple"ניצחה בפעילות וכל שחקניה קיבלו על כך Ballas הקבוצה", GetNum(ActInfo[Reward]));
			}
		}
		if(ActInfo[Players] == 1 && ActInfo[Started])
		{
		    KillTimer(ActInfo[Timer]);
			ActInfo[Players] = 0;
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[ListItem] = 0;
			loop(i) if(InAct[i][ActIn])
			{
				InAct[i][ActIn] = false;
				SpawnPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerMoney(i, ActInfo[Reward]);
				Message(-1, Yellow, "!"green"$%s "yellow"וקיבל על כך "red"\"%s\" "yellow"המנצח בפעילות הינו", GetNum(ActInfo[Reward]), GetName(i));
			}
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(InAct[playerid][ActIn] && ActInfo[Started] && ActInfo[Active] == SWarActive)
	{
		DestroyVehicle(GetPlayerVehicleID(playerid));
		SpawnPlayer(playerid);
	    InAct[playerid][ActIn] = false;
		ActInfo[Players]--;
		SendClientMessage(playerid, -1, ".יצאת מן הרכב ולכן הפסדת בפעילות, בהצלחה בפעם הבאה");
		if(ActInfo[Players])
		{
		    KillTimer(ActInfo[Timer]);
			ActInfo[Players] = 0;
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[ListItem] = 0;
			loop(i) if(InAct[i][ActIn])
			{
				InAct[i][ActIn] = false;
				SpawnPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerMoney(playerid, ActInfo[Reward]);
				Message(-1, Yellow, "!"green"$%s "yellow"וקיבל על כך "red"\"%s\" "yellow"המנצח בפעילות הינו", GetNum(ActInfo[Reward]), GetName(i));
			}
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	ResetPlayerWeapons(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(InAct[playerid][ActIn])
	{
	    ActInfo[Players]--;
		InAct[playerid][ActIn] = false;
		SendClientMessage(playerid, -1, ".יצאת מן הפעילות");
	    if(ActInfo[Active] == TWarActive && ActInfo[Started])
		{
		    if(InAct[playerid][TWarPlayerID] == GroveTeam) ActInfo[GrovePlayers]--;
		    else if(InAct[playerid][TWarPlayerID] == BallasTeam) ActInfo[BallasPlayers]--;
		    if(ActInfo[BallasPlayers] > ActInfo[GrovePlayers] && !ActInfo[GrovePlayers])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = 0;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
				loop(i) if(InAct[i][ActIn])
				{
	   		 		SpawnPlayer(i);
					InAct[i][ActIn] = false;
					if(GetPlayerTeam(i) == BallasTeam) GivePlayerMoney(i, ActInfo[Reward]);
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				Message(-1, Purple, "!"green"$%s "purple"ניצחה בפעילות וכל שחקניה קיבלו על כך Ballas הקבוצה", GetNum(ActInfo[Reward]));

		    }
		    else if(ActInfo[BallasPlayers] < ActInfo[GrovePlayers] && !ActInfo[BallasPlayers])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = 0;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
	   		 	loop(i) if(InAct[i][ActIn])
				{
	   		 		SpawnPlayer(i);
					InAct[i][ActIn] = false;
					if(GetPlayerTeam(i) == GroveTeam) GivePlayerMoney(i, ActInfo[Reward]);
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				Message(-1, Green, "!$%s ניצחה בפעילות וכל שחקניה קיבלו על כך Grove הקבוצה", GetNum(ActInfo[Reward]));
		    }
		    else if(!ActInfo[GrovePlayers] && !ActInfo[BallasPlayers])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = 0;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
              	loop(i) if(InAct[i][ActIn])
              	{
					SpawnPlayer(i);
					InAct[i][ActIn] = false;
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				SendClientMessageToAll(Yellow, ".אף קבוצה אינה ניצחה בפעילות");
		    }
		}
  		if(ActInfo[Players] == 1 && ActInfo[Started])
		{
			KillTimer(ActInfo[Timer]);
			loop(i) if(InAct[i][ActIn])
			{
			    if(ActInfo[Active] == SWarActive) DestroyVehicle(GetPlayerVehicleID(i));
				InAct[i][ActIn] = false;
				SpawnPlayer(i);
				ResetPlayerWeapons(i);
				GivePlayerMoney(i, ActInfo[Reward]);
<<<<<<< HEAD
    			Message(-1, Yellow, "!"green"$%s "yellow"����� �� �� "red"\"%s\" "yellow"����� ������� ����", GetNum(ActInfo[Reward]), GetName(i));
=======
    			Message(-1, Yellow, "! "green"$%s "yellow"וקיבל על כך "red"\"%s\" "yellow"המנצח בפעילות הינו", GetNum(ActInfo[Reward]), GetName(i));
>>>>>>> origin/master
			}
			ActInfo[Players] = 0;
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[ListItem] = 0;
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_STARTACT && response)
    {
        switch(listitem)
        {
            case 0: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startmini");
            case 1: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startwar");
            case 2: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startswar");
            case 3: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/starttwar");
            case 4: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startboom");
            case 5: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startbazooka");
            case 6: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startflame");
            case 7: CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startchain");
		}
        return 1;
    }

    if(dialogid == DIALOG_REWARD && !response) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startact");
    if(dialogid == DIALOG_REWARD && response)
    {
<<<<<<< HEAD
        if(!strlen(inputtext)) return SendClientMessage(playerid, Red, ".���� �� ���� ���� ������ ����");
        ActInfo[Active] = ActInfo[ListItem];
=======
        if(!strlen(inputtext)) return SendClientMessage(playerid, Red, ".הכנס את סכום הכסף שהוזכה יקבל");
        if(ActInfo[ListItem] == 0) ActInfo[Active] = MiniActive;
		else if(ActInfo[ListItem] == 1) ActInfo[Active] = WarActive;
		else if(ActInfo[ListItem] == 2) ActInfo[Active] = SWarActive;
		else if(ActInfo[ListItem] == 3) ActInfo[Active] = TWarActive;
		else if(ActInfo[ListItem] == 4) ActInfo[Active] = BoomActive;
		else if(ActInfo[ListItem] == 5) ActInfo[Active] = BazookaActive;

>>>>>>> origin/master
		ActInfo[RandomNum] = random(80);

        if(ActInfo[Active] == MiniActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startmini");
			SendClientMessageToAll(Orange, "------------- Minigun -------------");
		}
		else if(ActInfo[Active] == WarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startwar");
			SendClientMessageToAll(Orange, "------------- War -------------");
		}
		else if(ActInfo[Active] == SWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startswar");
			SendClientMessageToAll(Orange, "------------- SWar -------------");
			LoadSWarVehicles();
		}
        else if(ActInfo[Active] == TWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/starttwar");
			SendClientMessageToAll(Orange, "------------- TWar -------------");
		}
		else if(ActInfo[Active] == BoomActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startboom");
			SendClientMessageToAll(Orange, "------------- Boom -------------");
		}
		else if(ActInfo[Active] == BazookaActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startbazooka");
			SendClientMessageToAll(Orange, "------------- Bazooka -------------");
		}
		else if(ActInfo[Active] == FlameActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startflame");
			SendClientMessageToAll(Orange, "------------- Flame -------------");
		}
		else if(ActInfo[Active] == ChainActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return CallLocalFunction("OnPlayerCommandText", "ds", playerid, "/startchain");
			SendClientMessageToAll(Orange, "------------- Chain -------------");
		}

		if(ActInfo[Active] != 0)
		{
			KillTimer(ActInfo[Timer]);
		    ActInfo[GA] = playerid;
			ActInfo[atime] = gettime();
			ActInfo[Players] = 0;
			ActInfo[Timer] = SetTimer("StartACT", 850, 1);
			ActInfo[CD] = 30;
		}
		
		Message(-1, Orange, "/Join %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
		Message(-1, Orange, "!פרס למנצח: %s$", GetNum(ActInfo[Reward]));
		SendClientMessageToAll(Red, "!מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
		return SendClientMessageToAll(Orange, "--------------------------------------");
    }
	return 1;
}

public StartACT()
{
    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) SendClientMessageToAll(Pink, "/Join נשאר 15 שניות לתחילת הפעילות, הרשמו מהר");
    if(!ActInfo[CD])
    {
        KillTimer(ActInfo[Timer]);
    	if(ActInfo[Players] <= 1)
		{
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[Players] = 0;
			loop(i) InAct[i][ActIn] = false;
			return SendClientMessageToAll(Red, ".הפעילות בוטלה מכיוון שאין מספיק משתתפים");
		}
		ActInfo[Started] = true;
		ActInfo[CD] = IN_ACT_START_TIME + 1;
        switch(ActInfo[Active])
        {
            case MiniActive:
            {
				loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof MiniSpawns);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 0.0);
					SetPlayerInterior(i, 0);
					SetPlayerVirtualWorld(i, 10);
					SetPlayerPos(i, MiniSpawns[rand][0], MiniSpawns[rand][1], MiniSpawns[rand][2]);
					SetPlayerFacingAngle(i, MiniSpawns[rand][3]);
					SetCameraBehindPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerWeapon(i, 38, 9000);
					TogglePlayerControllable(i, 0);
				}
            }
			case WarActive:
			{
			    loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof WarSpawns);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 0.0);
					SetPlayerInterior(i, 10);
					SetPlayerVirtualWorld(i, 10);
					SetPlayerPos(i, WarSpawns[rand][0], WarSpawns[rand][1], WarSpawns[rand][2]);
					SetPlayerFacingAngle(i, WarSpawns[rand][3]);
					SetCameraBehindPlayer(i);
					ResetPlayerWeapons(i);
					GivePlayerWeapon(i, random(33-25)+25, 9000);
					TogglePlayerControllable(i, 0);
				}
			}
			case SWarActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
					SetPlayerVirtualWorld(i, 10);
					SetVehicleVirtualWorld(SWarVehicle[i], 10);
					PutPlayerInVehicle(i, SWarVehicle[i], 0);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 0.0);
					SetPlayerInterior(i, 0);
					SetCameraBehindPlayer(i);
					TogglePlayerControllable(i, 0);
				}
			}
			case TWarActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof GrovePos), rand2 = random(sizeof BallasPos);
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
					TogglePlayerControllable(i, 0);
				}
			}
   			case BoomActive, FlameActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof BoomAndFlameSpawns);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 0.0);
					SetPlayerInterior(i, 0);
					SetPlayerVirtualWorld(i, 10);
					SetPlayerPos(i, BoomAndFlameSpawns[rand][0], BoomAndFlameSpawns[rand][1], BoomAndFlameSpawns[rand][2]);
					SetPlayerFacingAngle(i, BoomAndFlameSpawns[rand][3]);
					SetCameraBehindPlayer(i);
					ResetPlayerWeapons(i);
					if(ActInfo[Active] == FlameActive) GivePlayerWeapon(i, 37, 9000);
					TogglePlayerControllable(i, 0);
				}
			}
			case BazookaActive, ChainActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof BazookaAndChainSpawns);
					SetPlayerHealth(i, 100);
					SetPlayerArmour(i, 0.0);
					SetPlayerInterior(i, 15);
					SetPlayerVirtualWorld(i, 10);
					SetPlayerPos(i, BazookaAndChainSpawns[rand][0], BazookaAndChainSpawns[rand][1], BazookaAndChainSpawns[rand][2]);
					SetPlayerFacingAngle(i, BazookaAndChainSpawns[rand][3]);
					SetCameraBehindPlayer(i);
					if(ActInfo[Active] == BazookaActive) GivePlayerWeapon(i, 35, 850);
					else GivePlayerWeapon(i, 9, 850);
					TogglePlayerControllable(i, 0);
				}
			}
        }
        ActInfo[Timer] = SetTimer("ACTStarted", 850, 1);
    }
    else
    {
        format(String, 64, "~y~[] ~r~/Join %d: ~b~%d~y~[]", ActInfo[RandomNum], ActInfo[CD]);
       	GameTextForAll(String, 1000, 4);
		if(ActInfo[Players] == 30)
		{
			SendClientMessageToAll(Red, ".כל המקומות בפעילות נתפסו");
			ActInfo[Players] = 31;
		}
    }
	ActInfo[CD]--;
	return 1;
}

public ACTStarted()
{
	if(ActInfo[Started])
	{
		if(ActInfo[CD] <= 0)
	    {
	    	KillTimer(ActInfo[Timer]);
			loop(i) if(InAct[i][ActIn]) TogglePlayerControllable(i, 1), GameTextForPlayer(i, "~g~Good ~y~Luck~w~!", 2000, 3);
			if(ActInfo[Active] == BoomActive) ActInfo[Timer] = SetTimer("RandBoom", 1000, 1);
			else if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 800, 0);
		}
		else loop(i) if(InAct[i][ActIn])
		{
			new color[][] = {
		        "~r~",
				"~w~",
				"~y~",
				"~g~",
				"~b~"
		    };
			format(String, 7, "%s%d", color[random(sizeof color)], ActInfo[CD]);
			GameTextForPlayer(i, String, 1000, 4);
			if(ActInfo[Active] == SWarActive && ActInfo[CD] == IN_ACT_START_TIME - 2)
			{
			    SetVehicleToRespawn(SWarVehicle[i]);
				PutPlayerInVehicle(i, SWarVehicle[i], 0);
			}
		}
	}
	ActInfo[CD]--;
	return 1;
}

public RandBoom()
{
    new rand = random(sizeof RandomBoom);
    for(new i; i < 10; i++) CreateExplosion(RandomBoom[rand][0], RandomBoom[rand][1], RandomBoom[rand][2], 2, 3);
	return 1;
}

public IsPlayerInWater()
{
	loop(i) if(IsPlayerWithVehicleInWater(i))
	{
	    DestroyVehicle(GetPlayerVehicleID(i));
		SetPlayerHealth(i, 0.0);
		SendClientMessage(i, -1, ".נפלת למים אם הרכב ולכן הפסדת בפעילות, בהצלחה בפעמים הבאות");
  	}
  	if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 800, 0);
	return 1;
}

public AutoAct()
{
    if(ActInfo[Active] != 0) return print("Activity Active...");
	switch(random(7))
	{
	    case 0:
	    {
	        ActInfo[Reward] = MiniAutoActReward;
			ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = MiniActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- Mini -------------");
		}
	    case 1:
	    {
	        ActInfo[Reward] = WarAutoActReward;
			ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = WarActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- War -------------");
		}
	    case 2:
	    {
	        ActInfo[Reward] = SWarAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = SWarActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- SWar -------------");
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
			SendClientMessageToAll(Orange, "------------- TWar -------------");
		}
	    case 4:
	    {
	        ActInfo[Reward] = BoomAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = BoomActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- Boom -------------");
		}
		case 5:
		{
		    ActInfo[Reward] = BazookaAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = BazookaActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- Bazooka -------------");
		}
		case 6:
		{
		    ActInfo[Reward] = FlameAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = FlameActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- Flame -------------");
		}
		case 7:
		{
		    ActInfo[Reward] = ChainAutoActReward;
	        ActInfo[GA] = -1;
			ActInfo[atime] = gettime();
			ActInfo[RandomNum] = random(80);
			ActInfo[Active] = ChainActive;
			ActInfo[Players] = 0;
			SendClientMessageToAll(Orange, "------------- Chain -------------");
		}
	}
	Message(-1, Orange, "/Join %d הפעילות החלה ! - בכדי להרשם לפעילות הקש", ActInfo[RandomNum]);
	Message(-1, Orange, "!פרס למנצח: %s$", GetNum(ActInfo[Reward]));
	SendClientMessageToAll(Red, "!מספר המקומות מוגבל לשלושים שחקנים בלבד, הרשמו מהר");
	SendClientMessageToAll(Orange, "----------------------------------");
	ActInfo[Timer] = SetTimer("StartACT", 850, 1);
	ActInfo[CD] = 30;
	return 1;
}

//=== Commands
public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!IsPlayerAdmin(playerid) && InAct[playerid][ActIn] && (strcmp("/twarplayers", cmdtext, true) || strcmp("/act", cmdtext, true) || IsPlayerAdmin(playerid) && strcmp("/stopact", cmdtext, true)))
		return SendClientMessage(playerid, Red, ".אינך יכול לבצע פקודות כאשר אתה בפעילות"), 0;
	dcmd(act, 3, cmdtext);
	dcmd(startact, 8, cmdtext);
	dcmd(stopact, 7, cmdtext);
	dcmd(join, 4, cmdtext);
	dcmd(startmini, 9, cmdtext);
	dcmd(startwar, 8, cmdtext);
	dcmd(startswar, 9, cmdtext);
	dcmd(starttwar, 9, cmdtext);
	dcmd(startboom, 9, cmdtext);
	dcmd(startbazooka, 12, cmdtext);
	dcmd(startflame, 10, cmdtext);
	dcmd(startchain, 10, cmdtext);
	dcmd(twarplayers, 11, cmdtext);
	return 0;
}

dcmd_act(playerid, params[])
{
    #pragma unused params
	new time2 = gettime()-ActInfo[atime], hour, minute, second;
	second = time2 % 60;
	time2 /= 60;
	minute = time2 % 60;
	time2 /= 60;
	hour = time2 % 24;
	String[0] = EOS;
	switch(ActInfo[Active])
	{
	    case MiniActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Mini הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Mini הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case WarActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,War הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,War הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case SWarActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,SWar הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,SWar הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case TWarActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,TWar הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,TWar הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case BoomActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Boom הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Boom הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case BazookaActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Bazooka הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Bazooka הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    case FlameActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Flame"white"]\n%02d:%02d:%02d :הופעלה אוטומטית ע\"י המערכת ופעילה ,Flame הפעילות", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Flame"white"]\n%02d:%02d:%02d :ופעילה %s :הופעלה ע\"י ,Flame הפעילות", hour, minute, second, GetName(ActInfo[GA]));
	    }
<<<<<<< HEAD
	    case ChainActive:
	    {
	        if(ActInfo[GA] == -1) format(String, sizeof String, ""white"["orange"Chain"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,Chain �������", hour, minute, second);
	        else format(String, sizeof String, ""white"["orange"Chain"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,Chain �������", hour, minute, second, GetName(ActInfo[GA]));
	    }
	    default: return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", ".��� ������ ����", "�����", "");
=======
	    default: return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", ".אין פעילות כרגע", "אישור", "");
>>>>>>> origin/master
	}
	return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "מצב הפעילויות בשרת", String, "אישור", "");
}

dcmd_startact(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] == MiniActive) Mini = " - "green"����"white"";
	else if(ActInfo[Active] == WarActive) War = " - "green"����"white"";
	else if(ActInfo[Active] == SWarActive) Swar = " - "green"����"white"";
	else if(ActInfo[Active] == TWarActive) Twar = " - "green"����"white"";
	else if(ActInfo[Active] == BoomActive) Boom = " - "green"����"white"";
	else if(ActInfo[Active] == BazookaActive) Bazooka = " - "green"����"white"";
	else if(ActInfo[Active] == FlameActive) Flame = " - "green"����"white"";
	else if(ActInfo[Active] == ChainActive) Chain = " - "green"����"white"";
	String[0] = EOS;
	format(String, sizeof String, "Minigun [/StartMini]%s\nWar [/StartWar]%s\nSultan Wars [/StartSWar]%s\nTeam War [/StartTWar]%s\nBoom [/StartBoom]%s\nBazooka [/StartBazooka]%s\nFlame [/StartFlame]%s\nChain [/StartChain]%s", Mini, War, Swar, Twar, Boom, Bazooka, Flame, Chain);
	return ShowPlayerDialog(playerid, DIALOG_STARTACT, DIALOG_STYLE_LIST, "��������", String, "����", "�����");
=======
	if(ActInfo[Active] == MiniActive) Mini = ""green"פועל"white"";
	else if(ActInfo[Active] == WarActive) War = ""green"פועל"white"";
	else if(ActInfo[Active] == SWarActive) Swar = ""green"פועל"white"";
	else if(ActInfo[Active] == TWarActive) Twar = ""green"פועל"white"";
	else if(ActInfo[Active] == BoomActive) Boom = ""green"פועל"white"";
	else if(ActInfo[Active] == BazookaActive) Bazooka = ""green"פועל"white"";
	String[0] = EOS;
	format(String, sizeof String, "Minigun [/StartMini] - %s\nWar [/StartWar] - %s\nSultan Wars [/StartSWar] - %s\nTeam War [/StartTWar] - %s\nBoom [/StartBoom] - %s\nBazooka [/StartBazooka] - %s", Mini, War, Swar, Twar, Boom, Bazooka);
	return ShowPlayerDialog(playerid, DIALOG_STARTACT, DIALOG_STYLE_LIST, "פעילויות", String, "הפעל", "ביטול");
>>>>>>> origin/master
}

dcmd_stopact(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
    if(!ActInfo[Active]) return SendClientMessage(playerid, Red, ".אין פעילות כרגע");
	ActInfo[Players] = 0;
	ActInfo[GrovePlayers] = 0;
	ActInfo[BallasPlayers] = 0;
	ActInfo[Active] = 0;
	ActInfo[ListItem] = 0;
    loop(i) if(InAct[i][ActIn])
	{
		if(ActInfo[Started])
		{
		    TogglePlayerControllable(i, 1);
		    SetPlayerTeam(i, NO_TEAM);
			SpawnPlayer(i);
		}
		InAct[i][ActIn] = false;
	}
	ActInfo[Started] = false;
	Message(-1, Red, ".ביטל את הפעילות \"%s\" האדמין", GetName(playerid));
	return KillTimer(ActInfo[Timer]);
}

dcmd_join(playerid, params[])
{
	if(!ActInfo[Active]) return SendClientMessage(playerid, Red, ".אין פעילות כעת");
	if(ActInfo[Started]) return SendClientMessage(playerid, -1, ".הפעילות כבר החלה");
	if(ActInfo[Players] >= 30) return SendClientMessage(playerid, Red, ".כל המקומות נתפסו");
	if(InAct[playerid][ActIn]) return  SendClientMessage(playerid, Red, ".הצטרפת כבר לפעילות");
	if(sscanf(params, "d", ActInfo[num]) || ActInfo[num] != ActInfo[RandomNum]) return Message(playerid, Red, "/Join %d", ActInfo[RandomNum]);
	ActInfo[Players]++;
	Message(playerid, Yellow, "[%d/30] .הצטרפת לפעילות", ActInfo[Players]);
	if(ActInfo[Active] == TWarActive)
	{
  		if(ActInfo[Players] % 2 == 0)
		{
			ActInfo[GrovePlayers]++;
			InAct[playerid][TWarPlayerID] = GroveTeam;
		}
		else
		{
			ActInfo[BallasPlayers]++;
			InAct[playerid][TWarPlayerID] = BallasTeam;
		}
		Message(playerid, -1, "%s", InAct[playerid][TWarPlayerID] == GroveTeam ? (""green"Grove :קבוצה") : (""purple"Ballas :קבוצה"));
	}
	return InAct[playerid][ActIn] = true, 1;
}

//============================= [ Minigun ] ====================================
dcmd_startmini(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = MiniActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Minigun", ".��� ��� �� ���� ���� ������ ����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 0;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Minigun", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
>>>>>>> origin/master
}

//================================= [ War ] ====================================
dcmd_startwar(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = WarActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "War", ".��� ��� �� ���� ���� ������ ����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 1;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "War", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
>>>>>>> origin/master
}

//============================ [ Sultan Wars ] =================================
dcmd_startswar(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = SWarActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Sultan Wars", ".��� ��� �� ���� ���� ������ ����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 2;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Sultan Wars", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
>>>>>>> origin/master
}

//============================ [ Team War ] ====================================
dcmd_starttwar(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = TWarActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Team War", ".��� ��� �� ���� ���� ������� �����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 3;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Team War", ".אנא הקש את סכום הכסף שהזוכים יקבלו", "הפעל", "חזרה");
>>>>>>> origin/master
}

dcmd_twarplayers(playerid, params[])
{
    #pragma unused params
    if(ActInfo[Active] != TWarActive) return SendClientMessage(playerid, -1, ".הפעילות אינה פועלת כרגע");
    if(!ActInfo[Started]) return SendClientMessage(playerid, -1, ".הפעילות אינה החלה");
    String[0] = EOS;
	loop(i) if(InAct[i][ActIn])
    	format(String, sizeof String, ""white"%s\n• %s | %s", String, GetName(i), (GetPlayerTeam(i)) ? (""green"Grove") : (""purple"Ballas"));
    return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, ""green"Team "red"War "white"Players", String, "אישור", "");
}

//============================== [ Boom ] ======================================
dcmd_startboom(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = BoomActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Boom", ".��� ��� �� ���� ���� ������ ����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 4;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Boom", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
>>>>>>> origin/master
}

//============================= [ Bazooka ] ====================================
dcmd_startbazooka(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
<<<<<<< HEAD
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = BazookaActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Bazooka", ".��� ��� �� ���� ���� ������ ����", "����", "����");
=======
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".יש פעילות שפעולת, המתן לסיומה");
	ActInfo[ListItem] = 5;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Bazooka", ".אנא הקש את סכום הכסף שהזוכה יקבל", "הפעל", "חזרה");
>>>>>>> origin/master
}

//============================= [ Flame ] ====================================
dcmd_startflame(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = FlameActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Flame", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

//============================= [ Flame ] ====================================
dcmd_startchain(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = ChainActive;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Chain", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

PlayerConnect(playerid)
{
    GetPlayerName(playerid, GetName(playerid), MAX_PLAYER_NAME);
	return InAct[playerid][ActIn] = false, 1;
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
	return 1;
}

stock bool:IsPlayerWithVehicleInWater(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return false;
    new Float:z;
    GetVehiclePos(GetPlayerVehicleID(playerid), z, z, z);
    return (z <= 0) ? true : false;
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

stock Message(playerid, color, form[], {Float, _}: ...)
{
    #pragma unused form
    static tmp[128];
    new t1 = playerid, t2 = color;
    const n4 = -4, n16 = -16, size = sizeof tmp;
    #emit stack 28
    #emit push.c size
    #emit push.c tmp
    #emit stack n4
    #emit sysreq.c format
    #emit stack n16
    if(t1 != -1) return SendClientMessage(t1, t2, tmp);
    else return SendClientMessageToAll(t2, tmp);
}

//=== Act על הזמנים של ה make_belive קרדיט ל
