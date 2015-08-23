#include <a_samp>
#include <streamer>

#define DIALOG_PIZZA        890
#define GetName(%0)         pM[playerid][PlayerName]

enum PizzaMission
{
	PlayerName[MAX_PLAYER_NAME+1],
    bool: InPizza,
	PizzaMin,
	PizzaSec,
	PizzaCP,
	Text3D:Pizza3D,
	PizzaTimer,
	PizzaRandomSec,
	PizzaTime,
	bool: InPizzaVehicle,
	PizzaVehicleID,
	PlayerText:Textdraw[3]
}

new
	pM[MAX_PLAYERS][PizzaMission],
	PizzaVehicle[7],
	PizzaVehicleIn[7],
	Float:Pos[3],
	g_String[54+MAX_PLAYER_NAME+MAX_PLAYER_NAME],
	RandomPizzaSec[] = {0, 30}
	;
	
new Float:PizzaRandomCP[][3] =
{
	{-2064.064453, 227.789276, 35.531978},
	{-1673.984619, 440.004394, 7.106770},
	{-2577.400146, 917.541259, 64.682029},
	{-2671.761230, 904.996093, 79.405052},
	{-2830.261962, 863.701660, 43.662799},
	{-1731.353149, 1423.985595, 6.869708},
	{-2381.176269, 497.910644, 29.369056}
};

forward TimeMission(playerid);

public OnFilterScriptInit()
{
    PizzaVehicle[0] = AddStaticVehicle(448, -1806.479003, 945.612304, 24.491041, 228.522476, 3, 6);
	PizzaVehicle[1] = AddStaticVehicle(448, -1808.563720, 943.527648, 24.485528, 223.012130, 3, 6);
	PizzaVehicle[2] = AddStaticVehicle(448, -1810.550659, 942.814819, 24.460639, 203.407333, 3, 6);
	PizzaVehicle[3] = AddStaticVehicle(448, -1805.538208, 947.409179, 24.490127, 239.886566, 3, 6);
	PizzaVehicle[4] = AddStaticVehicle(448, -1805.117309, 950.954162, 24.489536, 268.037872, 3, 6);
	PizzaVehicle[5] = AddStaticVehicle(448, -1805.162231, 953.408447, 24.489587, 266.508819, 3, 6);
	PizzaVehicle[6] = AddStaticVehicle(448, -1805.261840, 956.282897, 24.490293, 265.486083, 3, 6);
	
	for(new i; i < 7; i++)
		CreateDynamic3DTextLabel("משימת הפיצה", 0xFF0000FF, 0.0, 0.0, 1.2, 25, INVALID_PLAYER_ID, PizzaVehicle[i], 0, 0, -1, -1, 25),
		    PizzaVehicleIn[i] = -1;
		
	for(new i; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i))
		OnPlayerConnect(i);
	return true;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, pM[playerid][PlayerName], MAX_PLAYER_NAME);

    pM[playerid][Textdraw][2] = CreatePlayerTextDraw(playerid, 378.000000, 26.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, pM[playerid][Textdraw][2], 255);
	PlayerTextDrawFont(playerid, pM[playerid][Textdraw][2], 1);
	PlayerTextDrawLetterSize(playerid, pM[playerid][Textdraw][2], 0.500000, 4.999999);
	PlayerTextDrawColor(playerid, pM[playerid][Textdraw][2], -1);
	PlayerTextDrawSetOutline(playerid, pM[playerid][Textdraw][2], 0);
	PlayerTextDrawSetProportional(playerid, pM[playerid][Textdraw][2], 1);
	PlayerTextDrawSetShadow(playerid, pM[playerid][Textdraw][2], 1);
	PlayerTextDrawUseBox(playerid, pM[playerid][Textdraw][2], 1);
	PlayerTextDrawBoxColor(playerid, pM[playerid][Textdraw][2], 125);
	PlayerTextDrawTextSize(playerid, pM[playerid][Textdraw][2], 463.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, pM[playerid][Textdraw][2], 0);

	pM[playerid][Textdraw][0] = CreatePlayerTextDraw(playerid, 378.000000, 27.000000, "Mission Time:");
	PlayerTextDrawBackgroundColor(playerid, pM[playerid][Textdraw][0], 255);
	PlayerTextDrawFont(playerid, pM[playerid][Textdraw][0], 2);
	PlayerTextDrawLetterSize(playerid, pM[playerid][Textdraw][0], 0.300000, 1.499999);
	PlayerTextDrawColor(playerid, pM[playerid][Textdraw][0], -1);
	PlayerTextDrawSetOutline(playerid, pM[playerid][Textdraw][0], 0);
	PlayerTextDrawSetProportional(playerid, pM[playerid][Textdraw][0], 1);
	PlayerTextDrawSetShadow(playerid, pM[playerid][Textdraw][0], 1);
	PlayerTextDrawSetSelectable(playerid, pM[playerid][Textdraw][0], 0);

	pM[playerid][Textdraw][1] = CreatePlayerTextDraw(playerid, 393.000000, 46.000000, "00:00");
	PlayerTextDrawBackgroundColor(playerid, pM[playerid][Textdraw][1], 65535);
	PlayerTextDrawFont(playerid, pM[playerid][Textdraw][1], 1);
	PlayerTextDrawLetterSize(playerid, pM[playerid][Textdraw][1], 0.480000, 2.200000);
	PlayerTextDrawColor(playerid, pM[playerid][Textdraw][1], -1);
	PlayerTextDrawSetOutline(playerid, pM[playerid][Textdraw][1], 1);
	PlayerTextDrawSetProportional(playerid, pM[playerid][Textdraw][1], 1);
	PlayerTextDrawSetSelectable(playerid, pM[playerid][Textdraw][1], 0);
	return true;
}

public OnPlayerDisconnect(playerid, reason)
	return pM[playerid][PlayerName][0] = EOS;

public OnPlayerDeath(playerid, killerid, reason)
{
    if(pM[playerid][InPizza])
	{
	    for(new t; t < 3; t++) PlayerTextDrawHide(playerid, pM[playerid][Textdraw][t]);
	    KillTimer(pM[playerid][PizzaTimer]);
	    pM[playerid][InPizza] = false;
	    pM[playerid][InPizzaVehicle] = false;
	    SetVehicleToRespawn(pM[playerid][PizzaVehicleID]);
	    PizzaVehicleIn[pM[playerid][PizzaVehicleID]] = -1;
	    DestroyDynamicRaceCP(pM[playerid][PizzaCP]);
	    DestroyDynamic3DTextLabel(pM[playerid][Pizza3D]);
		if(killerid != INVALID_PLAYER_ID)
		{
		    GivePlayerMoney(killerid, 2500);
		    format(g_String, sizeof g_String, "[Pizza Mission] >> ! וזכה ב 2500$ %s הרג את השחקן %s השחקן", GetName(playerid), GetName(killerid));
		    SendClientMessageToAll(-1, g_String);
		}
		else
		{
   			format(g_String, sizeof g_String, "[Pizza Mission] >> ! נהרג / יצא מן הרכב %s השחקן", GetName(playerid));
		    SendClientMessageToAll(-1, g_String);
		}
	}
	return true;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_DRIVER)
	{
	    if(newstate == PLAYER_STATE_ONFOOT)
	    {
		    if(pM[playerid][InPizza])
			{
			    pM[playerid][PizzaTime] = 10;
			    pM[playerid][InPizzaVehicle] = false;
				return SendClientMessage(playerid, 0xFF0000FF, ".יש לך 10 שניות לחזור לאופנוע ולא תפסיד");
			}
		}
	}
	
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(PizzaVehicleIn[vehicleid] != playerid && PizzaVehicleIn[vehicleid] != -1)
	    {
	        SendClientMessage(playerid, -1, ".יש שחקן שמבצע משלוח באופנוע זה");
	        return RemovePlayerFromVehicle(playerid);
	    }
    	else if(!pM[playerid][InPizza])
    	{
    	    for(new i; i < 7; i++) if(vehicleid == PizzaVehicle[i])
		    	return ShowPlayerDialog(playerid, DIALOG_PIZZA, DIALOG_STYLE_MSGBOX, "Pizza Mission", "במשימה זו תצטרך להעביר משלוח פיצה לבית נבחר בזמן\nאם תספיק להעביר את הפיצה בזמן תזכה בכסף\nאם לא תספיק תפסיד במשימה", "התחל", "ביטול");
		}
		else
		{
		    for(new i; i < 7; i++) if(vehicleid == PizzaVehicle[i])
		    {
				pM[playerid][InPizzaVehicle] = true;
				return SendClientMessage(playerid, -1, ".המשך במשימתך");
			}
		}
	}
	return true;
}

public OnPlayerEnterDynamicRaceCP(playerid, checkpointid)
{
	if(checkpointid == pM[playerid][PizzaCP])
	{
	    for(new t; t < 3; t++) PlayerTextDrawHide(playerid, pM[playerid][Textdraw][t]);
	    DestroyDynamicRaceCP(pM[playerid][PizzaCP]);
	    DestroyDynamic3DTextLabel(pM[playerid][Pizza3D]);
     	KillTimer(pM[playerid][PizzaTimer]);
	    pM[playerid][InPizza] = false;
	    PizzaVehicleIn[GetPlayerVehicleID(playerid)] = -1;
	    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	    GivePlayerMoney(playerid, 6000);
		format(g_String, sizeof g_String, "[Pizza Mission] >> ! הצליח להעביר משלוח וזה ב 6000$ %s השחקן", GetName(playerid));
		return SendClientMessageToAll(0xFF0000FF, g_String);
	}
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(pM[playerid][InPizza])
	    return SendClientMessage(playerid, -1, ".אינך יכול לבצע פקודות כאשר אתה במשימת הפיצה");

	if(!strcmp(cmdtext, "/sf", true))
	{
	    SetPlayerPos(playerid, -1912.7299, 883.0395, 35.2630);
	    return SetPlayerFacingAngle(playerid, 270.1409);
	}
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_PIZZA && !response) return RemovePlayerFromVehicle(playerid);
	else if(dialogid == DIALOG_PIZZA && response)
	{
	    new rand = random(sizeof PizzaRandomCP);
	    Pos[0] = PizzaRandomCP[rand][0];
	    Pos[1] = PizzaRandomCP[rand][1];
	    Pos[2] = PizzaRandomCP[rand][2];
		pM[playerid][InPizza] = true;
        pM[playerid][InPizzaVehicle] = true;
        pM[playerid][PizzaVehicleID] = GetPlayerVehicleID(playerid);
        PizzaVehicleIn[GetPlayerVehicleID(playerid)] = playerid;
		pM[playerid][PizzaMin] = 0;
		pM[playerid][PizzaSec] = 0;
		pM[playerid][PizzaTime] = 10;
		pM[playerid][PizzaCP] = CreateDynamicRaceCP(1, Pos[0], Pos[1], Pos[2], 0.0, 0.0, 0.0, 2.5, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 2500);
		pM[playerid][Pizza3D] = CreateDynamic3DTextLabel("יעד הפיצה", 0xFF0000FF, Pos[0], Pos[1], Pos[2], 2500, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 2500);
        PlayerTextDrawSetString(playerid, pM[playerid][Textdraw][1], "00:00");
		for(new t; t < 3; t++) PlayerTextDrawShow(playerid, pM[playerid][Textdraw][t]);
		pM[playerid][PizzaRandomSec] = RandomPizzaSec[random(sizeof RandomPizzaSec)];
		pM[playerid][PizzaTimer] = SetTimerEx("TimeMission", 950, true, "i", playerid);
		format(g_String, sizeof g_String, ".יש לך 01:%02d להגיע ליעד הפיצה", pM[playerid][PizzaRandomSec]);
		return SendClientMessage(playerid, 0xFF0000FF, g_String);
	}
	return true;
}

public TimeMission(playerid)
{
    if(pM[playerid][InPizza] && pM[playerid][InPizzaVehicle])
	{
	    format(g_String, sizeof g_String, "%02d:%02d", pM[playerid][PizzaMin], pM[playerid][PizzaSec]);
	    PlayerTextDrawSetString(playerid, pM[playerid][Textdraw][1], g_String);
	    pM[playerid][PizzaSec]++;
	    if(pM[playerid][PizzaSec] >= pM[playerid][PizzaRandomSec] && pM[playerid][PizzaMin] >= 1) return SetPlayerHealth(playerid, 0.0);
		else if(pM[playerid][PizzaSec] >= 60)
		{
		    pM[playerid][PizzaSec] = 0;
		    pM[playerid][PizzaMin]++;
		}
	}
	else if(pM[playerid][InPizza] && !pM[playerid][InPizzaVehicle])
	{
	    if(pM[playerid][PizzaTime] != 0)
	    {
	        format(g_String, sizeof g_String, "~r~%d", pM[playerid][PizzaTime]);
		    GameTextForPlayer(playerid, g_String, 1000, 3);
		    pM[playerid][PizzaTime]--;
		}
		else SetPlayerHealth(playerid, 0.0);
	}
	return true;
}
