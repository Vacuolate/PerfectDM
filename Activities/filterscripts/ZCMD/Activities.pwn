#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <Spawns>

#define loop(%0)					for(new %0, lastid = GetPlayerPoolSize(); %0 < lastid; %0++)
#define GetName(%0)             	InAct[%0][Name]

#define STARTTIME               15

#define MiniActive              1
#define WarActive               2
#define SWarActive              3
#define TWarActive              4
#define BoomActive              5
#define BazookaActive           6
#define FlameActive           6

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

//=== Colors
#define Aqua    			0x00FFFFFF
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
	Flame[21],
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
				ActInfo[ListItem] = -1;
				loop(i) if(InAct[i][ActIn] && GetPlayerTeam(playerid) == GroveTeam)
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
				Message(-1, Green, "!$%s ����� ������� ��� ������ ����� �� �� Grove ������", GetNum(ActInfo[Reward]));
			}
			if(ActInfo[BallasPlayers] >= 1 && !ActInfo[GrovePlayers])
			{
			    KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
				loop(i) if(InAct[i][ActIn] && GetPlayerTeam(playerid) == BallasTeam)
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
				Message(-1, Purple, "!"green"$%s "purple"����� ������� ��� ������ ����� �� �� Ballas ������", GetNum(ActInfo[Reward]));
			}
		}
		if(ActInfo[Players] == 1 && ActInfo[Started])
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
				Message(-1, Yellow, "!"green"$%s "yellow"����� �� �� "red"\"%s\" "yellow"����� ������� ����", GetNum(ActInfo[Reward]), GetName(i));
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
		SendClientMessage(playerid, -1, ".���� �� ���� ���� ����� �������, ������ ���� ����");
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
				Message(-1, Yellow, "!"green"$%s "yellow"����� �� �� "red"\"%s\" "yellow"����� ������� ����", GetNum(ActInfo[Reward]), GetName(i));
			}
		}
	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!IsPlayerAdmin(playerid) && InAct[playerid][ActIn] && (strcmp("/twarplayers", cmdtext, true) || strcmp("/act", cmdtext, true) || IsPlayerAdmin(playerid) && strcmp("/stopact", cmdtext, true)))
		return SendClientMessage(playerid, Red, ".���� ���� ���� ������ ���� ��� �������"), 0;
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
		SendClientMessage(playerid, -1, ".���� �� �������");
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
				ActInfo[ListItem] = -1;
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
				Message(-1, Purple, "!"green"$%s "purple"����� ������� ��� ������ ����� �� �� Ballas ������", GetNum(ActInfo[Reward]));
				
		    }
		    else if(ActInfo[BallasPlayers] < ActInfo[GrovePlayers] && !ActInfo[BallasPlayers])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
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
				Message(-1, Green, "!$%s ����� ������� ��� ������ ����� �� �� Grove ������", GetNum(ActInfo[Reward]));
		    }
		    else if(!ActInfo[GrovePlayers] && !ActInfo[BallasPlayers])
		    {
		        KillTimer(ActInfo[Timer]);
				ActInfo[Players] = 0;
				ActInfo[Active] = 0;
				ActInfo[Started] = false;
				ActInfo[ListItem] = -1;
				ActInfo[BallasPlayers] = 0;
				ActInfo[GrovePlayers] = 0;
              	loop(i) if(InAct[i][ActIn])
              	{
					SpawnPlayer(i);
					InAct[i][ActIn] = false;
					SetPlayerTeam(i, NO_TEAM);
					SetPlayerColor(i, rgba2hex(random(256), random(256), random(256), 50));
				}
				SendClientMessageToAll(Yellow, ".�� ����� ���� ����� �������");
		    }
		}
		if(ActInfo[Players] == 1 && ActInfo[Started])
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
    			Message(-1, Yellow, "! "green"$%s "yellow"����� �� �� "red"\"%s\" "yellow"����� ������� ����", GetNum(ActInfo[Reward]), GetName(i));
			}
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
            case 0: cmd_startmini(playerid, "");
            case 1: cmd_startwar(playerid, "");
            case 2: cmd_startswar(playerid, "");
            case 3: cmd_starttwar(playerid, "");
            case 4: cmd_startboom(playerid, "");
            case 5: cmd_startbazooka(playerid, "");
        }
        return 1;
    }

    if(dialogid == DIALOG_REWARD && !response) return cmd_startact(playerid, "");
    if(dialogid == DIALOG_REWARD && response)
    {
        if(!strlen(inputtext)) return SendClientMessage(playerid, Red, ".���� �� ���� ���� ������ ����");
        if(ActInfo[ListItem] == 0) ActInfo[Active] = MiniActive;
		else if(ActInfo[ListItem] == 1) ActInfo[Active] = WarActive;
		else if(ActInfo[ListItem] == 2) ActInfo[Active] = SWarActive;
		else if(ActInfo[ListItem] == 3) ActInfo[Active] = TWarActive;
		else if(ActInfo[ListItem] == 4) ActInfo[Active] = BoomActive;
		else if(ActInfo[ListItem] == 5) ActInfo[Active] = BazookaActive;
		
		ActInfo[RandomNum] = random(80);
		
        if(ActInfo[Active] == MiniActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_startmini(playerid, "");
			SendClientMessageToAll(Orange, "------------- Minigun -------------");
		}
		else if(ActInfo[Active] == WarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_startwar(playerid, "");
			SendClientMessageToAll(Orange, "------------- War -------------");
		}
		else if(ActInfo[Active] == SWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_startswar(playerid, "");
			SendClientMessageToAll(Orange, "------------- SWar -------------");
			LoadSWarVehicles();
		}
        else if(ActInfo[Active] == TWarActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_starttwar(playerid, "");
			SendClientMessageToAll(Orange, "------------- TWar -------------");
		}
		else if(ActInfo[Active] == BoomActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_startboom(playerid, "");
			SendClientMessageToAll(Orange, "------------- Boom -------------");
		}
		else if(ActInfo[Active] == BazookaActive)
		{
		    if(sscanf(inputtext, "i", ActInfo[Reward])) return cmd_startbazooka(playerid, "");
			SendClientMessageToAll(Orange, "------------- Bazooka -------------");
		}
		
		Message(-1, Orange, "/Join %d ������� ���� ! - ���� ����� ������� ���", ActInfo[RandomNum]);
		Message(-1, Orange, "!��� �����: %s$", GetNum(ActInfo[Reward]));
		SendClientMessageToAll(Red, "!���� ������� ����� ������� ������ ����, ����� ���");
		SendClientMessageToAll(Orange, "--------------------------------------");
		
		if(ActInfo[Active] != 0)
		{
			KillTimer(ActInfo[Timer]);
		    ActInfo[GA] = playerid;
			ActInfo[atime] = gettime();
			ActInfo[Players] = 0;
			ActInfo[Timer] = SetTimer("StartACT", 1000, true);
			ActInfo[CD] = 30;
		}
        return 1;
    }
	return 1;
}

public StartACT()
{
    if(ActInfo[CD] == 15 && (ActInfo[Players] != 30 || ActInfo[Players] != 31)) SendClientMessageToAll(Pink, "/Join ���� 15 ����� ������ �������, ����� ���");
    if(!ActInfo[CD])
    {
        KillTimer(ActInfo[Timer]);
    	if(ActInfo[Players] <= 1)
		{
			ActInfo[Active] = 0;
			ActInfo[Started] = false;
			ActInfo[Players] = 0;
			loop(i) InAct[i][ActIn] = false;
			return SendClientMessageToAll(Red, ".������� ����� ������ ���� ����� �������");
		}
		ActInfo[Started] = true;
		ActInfo[CD] = 11;
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
					TogglePlayerControllable(i, false);
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
					TogglePlayerControllable(i, false);
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
					TogglePlayerControllable(i, false);
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
					TogglePlayerControllable(i, false);
				}
			}
			case BoomActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof BoomSpawns);
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
			}
			case BazookaActive:
			{
                loop(i) if(InAct[i][ActIn])
				{
				    new rand = random(sizeof BazookaSpawns);
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
			}
        }
        ActInfo[Timer] = SetTimer("ACTStarted", 1000, 1);
    }
    else
    {
        format(String, 64, "~y~[] ~r~/Join %d: ~b~%d~y~[]", ActInfo[RandomNum], ActInfo[CD]);
       	GameTextForAll(String, 1000, 4);
		if(ActInfo[Players] == 30)
		{
			SendClientMessageToAll(Red, ".�� ������� ������� �����");
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
			loop(i) if(InAct[i][ActIn])  TogglePlayerControllable(i, true), GameTextForPlayer(i, "Good Luck !", 2000, 3);
			if(ActInfo[Active] == BoomActive) ActInfo[Timer] = SetTimer("RandBoom", 1000, true);
			else if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 1000, false);
		}
		else loop(i) if(InAct[i][ActIn])
		{
			format(String, 7, "~r~$d", ActInfo[CD]);
			GameTextForPlayer(i, String, 1000, 4);
			if(ActInfo[Active] == SWarActive && ActInfo[CD] == 5)
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
		SendClientMessage(i, -1, ".���� ���� �� ���� ���� ����� �������, ������ ������ �����");
  	}
  	if(ActInfo[Active] == SWarActive) SetTimer("IsPlayerInWater", 1000, false);
	return 1;
}

public AutoAct()
{
    if(ActInfo[Active] != 0) return print("Activity Active ..");
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
	}
	Message(-1, Orange, "/Join %d ������� ���� ! - ���� ����� ������� ���", ActInfo[RandomNum]);
	Message(-1, Orange, "!��� �����: %s$", GetNum(ActInfo[Reward]));
	SendClientMessageToAll(Red, "!���� ������� ����� ������� ������ ����, ����� ���");
	SendClientMessageToAll(Orange, "----------------------------------");
	ActInfo[Timer] = SetTimer("StartACT", 1000, true);
	ActInfo[CD] = 30;
	return 1;
}

//=== Commands
CMD:act(playerid, params[])
{
	new time2 = gettime()-ActInfo[atime], hour, minute, second;
	second = time2 % 60;
	time2 /= 60;
	minute = time2 % 60;
	time2 /= 60;
	hour = time2 % 24;
	String[0] = EOS;

	if(ActInfo[Active] == MiniActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,Mini �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == MiniActive)
	{
		format(String, sizeof String, ""white"["orange"Mini"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,Mini �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}

	if(ActInfo[Active] == WarActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,War �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == WarActive)
	{
		format(String, sizeof String, ""white"["orange"War"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,War �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}

	if(ActInfo[Active] == SWarActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,SWar �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == SWarActive)
	{
		format(String, sizeof String, ""white"["orange"Sultan Wars"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,SWar �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}

	if(ActInfo[Active] == TWarActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,TWar �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == TWarActive)
	{
		format(String, sizeof String, ""white"["orange"Team War"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,TWar �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}

    if(ActInfo[Active] == BoomActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,Boom �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == BoomActive)
	{
		format(String, sizeof String, ""white"["orange"Boom"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,Boom �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	
	if(ActInfo[Active] == BazookaActive && ActInfo[GA] == -1)
	{
		format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :������ �������� �\"� ������ ������ ,Bazooka �������", hour, minute, second);
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	else if(ActInfo[Active] == BazookaActive)
	{
		format(String, sizeof String, ""white"["orange"Bazooka"white"]\n%02d:%02d:%02d :������ %s :������ �\"� ,Bazooka �������", hour, minute, second, GetName(ActInfo[GA]));
        return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", String, "�����", "");
	}
	return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, "��� ��������� ����", ".��� ������ ����", "�����", "");
}

CMD:startact(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] == MiniActive) Mini = ""green"����"white"";
	else if(ActInfo[Active] == WarActive) War = ""green"����"white"";
	else if(ActInfo[Active] == SWarActive) Swar = ""green"����"white"";
	else if(ActInfo[Active] == TWarActive) Twar = ""green"����"white"";
	else if(ActInfo[Active] == BoomActive) Boom = ""green"����"white"";
	else if(ActInfo[Active] == BazookaActive) Bazooka = ""green"����"white"";
	String[0] = EOS;
	format(String, sizeof String, "Minigun [/StartMini] - %s\nWar [/StartWar] - %s\nSultan Wars [/StartSWar] - %s\nTeam War [/StartTWar] - %s\nBoom [/StartBoom] - %s\nBazooka [/StartBazooka] - %s", Mini, War, Swar, Twar, Boom, Bazooka);
	return ShowPlayerDialog(playerid, DIALOG_STARTACT, DIALOG_STYLE_LIST, "��������", String, "����", "�����");
}

CMD:stopact(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return 0;
    if(!ActInfo[Active]) return SendClientMessage(playerid, Red, ".��� ������ ����");
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
	Message(-1, Red, ".���� �� ������� \"%s\" ������", GetName(playerid));
	return KillTimer(ActInfo[Timer]);
}

CMD:join(playerid, params[])
{
	if(!ActInfo[Active]) return SendClientMessage(playerid, Red, ".��� ������ ���");
	if(ActInfo[Started]) return SendClientMessage(playerid, -1, ".������� ��� ����");
	if(ActInfo[Players] >= 30) return SendClientMessage(playerid, Red, ".�� ������� �����");
	if(InAct[playerid][ActIn]) return  SendClientMessage(playerid, Red, ".������ ��� �������");
	if(sscanf(params, "d", ActInfo[num]) || ActInfo[num] != ActInfo[RandomNum]) return Message(playerid, Red, "/Join %d", ActInfo[RandomNum]);
	ActInfo[Players]++;
	Message(playerid, Yellow, "[%d/30] .������ �������", ActInfo[Players]);
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
		Message(playerid, -1, "%s", InAct[playerid][TWarPlayerID] == GroveTeam ? (""green"Grove :�����") : (""purple"Ballas :�����"));
	}
	return InAct[playerid][ActIn] = true;
}

//============================= [ Minigun ] ====================================
CMD:startmini(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 0;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Minigun", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

//================================= [ War ] ====================================
CMD:startwar(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 1;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "War", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

//============================ [ Sultan Wars ] =================================
CMD:startswar(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 2;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Sultan Wars", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

//============================ [ Team War ] ====================================
CMD:starttwar(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 3;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Team War", ".��� ��� �� ���� ���� ������� �����", "����", "����");
}

CMD:twarplayers(playerid, params[])
{
    if(ActInfo[Active] != TWarActive) return SendClientMessage(playerid, -1, ".������� ���� ����� ����");
    if(!ActInfo[Started]) return SendClientMessage(playerid, -1, ".������� ���� ����");
    String[0] = EOS;
	loop(i) if(InAct[i][ActIn])
    	format(String, sizeof String, ""white"%s\n� %s | %s", String, GetName(i), (GetPlayerTeam(i)) ? (""green"Grove") : (""purple"Ballas"));
    return ShowPlayerDialog(playerid, DIALOG_ACT, DIALOG_STYLE_MSGBOX, ""green"Team "red"War "white"Players", String, "�����", "");
}

//============================== [ Boom ] ======================================
CMD:startboom(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 4;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Boom", ".��� ��� �� ���� ���� ������ ����", "����", "����");
}

//============================= [ Bazooka ] ====================================
CMD:startbazooka(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	if(ActInfo[Active] != 0) return SendClientMessage(playerid, -1, ".�� ������ ������, ���� ������");
	ActInfo[ListItem] = 5;
	return ShowPlayerDialog(playerid, DIALOG_REWARD, DIALOG_STYLE_INPUT, "Bazooka", ".��� ��� �� ���� ���� ������ ����", "����", "����");
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
    static tmp[145];
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

//=== Act �� ������ �� � make_belive ����� �
