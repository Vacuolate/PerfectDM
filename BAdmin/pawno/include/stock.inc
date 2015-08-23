stock Message(playerid, color, const message[], va_args<>)
{
	va_format(g_String, sizeof g_String, message, va_start<3>);
	if(playerid == -1 || playerid == INVALID_PLAYER_ID)
	{
	    #pragma unused playerid
	    SendClientMessageToAll(color, g_String);
	} else SendClientMessage(playerid, color, g_String);
	return true;
}

stock BMessage(color, const message[])
{
	loop(i) if(IsBAdmin(i) && IsBLogged(playerid))
		return SendClientMessage(i, color, message);
	return true;
}

stock BMessage_(color, const message[], va_args<>)
{
	va_format(g_String, sizeof g_String, message, va_start<3>);
	loop(i) if(IsBAdmin(i) && IsBLogged(playerid))
		return SendClientMessage(i, color, g_String);
	return true;
}

stock GameText(playerid, const message[], time, style, va_args<>)
{
	va_format(g_String, sizeof g_String, message, va_start<4>);
	if(playerid == -1 || playerid == INVALID_PLAYER_ID)
	{
	    #pragma unused playerid
	    GameTextForAll(g_String, time, style);
	} else GameTextForPlayer(playerid, g_String, time, style);
	return true;
}

stock GetNum(number)
{
    new
        idx = 3,
		ret[18],
		size
		;
    valstr(ret, number);
    size = strlen(ret);
	while(idx < size)
	{
        strins(ret, ",", size-idx);
        idx += 3;
    }
    return ret;
}

stock GetWeaponID(weaponname[])
{
	for(new i = 0; i < 45; i++)
	{
		if(strfind(aWeaponNames[i], weaponname, true) != -1)
			return i;
	}
	return -1;
}

stock IsNumeric(const str[])
{
    for(new i, len = strlen(str); i < len; i++) if(!('0' <= str[i] <= '9')) return false;
    return true;
}

stock GetVehicleName(vehicleid)
{
	new vname[64];
	switch(GetVehicleModel(vehicleid))
	{
	   case 400: strcpy(vname, "Landstalker", sizeof vname);
	   case 401: strcpy(vname, "Bravura", sizeof vname);
	   case 402: strcpy(vname, "Buffalo", sizeof vname);
	   case 403: strcpy(vname, "Linerunner", sizeof vname);
	   case 404: strcpy(vname, "Perenniel", sizeof vname);
	   case 405: strcpy(vname, "Sentinel", sizeof vname);
	   case 406: strcpy(vname, "Dumper", sizeof vname);
	   case 407: strcpy(vname, "Firetruck", sizeof vname);
	   case 408: strcpy(vname, "Trashmaster", sizeof vname);
	   case 409: strcpy(vname, "Stretch", sizeof vname);
	   case 410: strcpy(vname, "Manana", sizeof vname);
	   case 411: strcpy(vname, "Infernus", sizeof vname);
	   case 412: strcpy(vname, "Voodoo", sizeof vname);
	   case 413: strcpy(vname, "Pony", sizeof vname);
	   case 414: strcpy(vname, "Mule", sizeof vname);
	   case 415: strcpy(vname, "Cheetah", sizeof vname);
	   case 416: strcpy(vname, "Ambulance", sizeof vname);
	   case 417: strcpy(vname, "Leviathan", sizeof vname);
	   case 418: strcpy(vname, "Moonbeam", sizeof vname);
	   case 419: strcpy(vname, "Esperanto", sizeof vname);
	   case 420: strcpy(vname, "Taxi", sizeof vname);
	   case 421: strcpy(vname, "Washington", sizeof vname);
	   case 422: strcpy(vname, "Bobcat", sizeof vname);
	   case 423: strcpy(vname, "Mr Whoopee", sizeof vname);
	   case 424: strcpy(vname, "BF Injection", sizeof vname);
	   case 425: strcpy(vname, "Hunter", sizeof vname);
	   case 426: strcpy(vname, "Premier", sizeof vname);
	   case 427: strcpy(vname, "Enforcer", sizeof vname);
	   case 428: strcpy(vname, "Securicar", sizeof vname);
	   case 429: strcpy(vname, "Banshee", sizeof vname);
	   case 430: strcpy(vname, "Predator", sizeof vname);
	   case 431: strcpy(vname, "Bus", sizeof vname);
	   case 432: strcpy(vname, "Rhino", sizeof vname);
	   case 433: strcpy(vname, "Barracks", sizeof vname);
	   case 434: strcpy(vname, "Hotknife", sizeof vname);
	   case 435: strcpy(vname, "Article Trailer", sizeof vname);
	   case 436: strcpy(vname, "Previon", sizeof vname);
	   case 437: strcpy(vname, "Coach", sizeof vname);
	   case 438: strcpy(vname, "Cabbie", sizeof vname);
	   case 439: strcpy(vname, "Stallion", sizeof vname);
	   case 440: strcpy(vname, "Rumpo", sizeof vname);
	   case 441: strcpy(vname, "RC Bandit", sizeof vname);
	   case 442: strcpy(vname, "Romero", sizeof vname);
	   case 443: strcpy(vname, "Packer", sizeof vname);
	   case 444: strcpy(vname, "Monster", sizeof vname);
	   case 445: strcpy(vname, "Admiral", sizeof vname);
	   case 446: strcpy(vname, "Squallo", sizeof vname);
	   case 447: strcpy(vname, "Seasparrow", sizeof vname);
	   case 448: strcpy(vname, "Pizzaboy", sizeof vname);
	   case 449: strcpy(vname, "Tram", sizeof vname);
	   case 450: strcpy(vname, "Article Trailer 2", sizeof vname);
	   case 451: strcpy(vname, "Turismo", sizeof vname);
	   case 452: strcpy(vname, "Speeder", sizeof vname);
	   case 453: strcpy(vname, "Reefer", sizeof vname);
	   case 454: strcpy(vname, "Tropic", sizeof vname);
	   case 455: strcpy(vname, "Flatbed", sizeof vname);
	   case 456: strcpy(vname, "Yankee", sizeof vname);
	   case 457: strcpy(vname, "Caddy", sizeof vname);
	   case 458: strcpy(vname, "Solair", sizeof vname);
	   case 459: strcpy(vname, "Berkley's RC Van", sizeof vname);
	   case 460: strcpy(vname, "Skimmer", sizeof vname);
	   case 461: strcpy(vname, "PCJ-600", sizeof vname);
	   case 462: strcpy(vname, "Faggio", sizeof vname);
	   case 463: strcpy(vname, "Freeway", sizeof vname);
	   case 464: strcpy(vname, "RC Baron", sizeof vname);
	   case 465: strcpy(vname, "RC Raider", sizeof vname);
	   case 466: strcpy(vname, "Glendale", sizeof vname);
	   case 467: strcpy(vname, "Oceanic", sizeof vname);
	   case 468: strcpy(vname, "Sanchez", sizeof vname);
	   case 469: strcpy(vname, "Sparrow", sizeof vname);
	   case 470: strcpy(vname, "Patriot", sizeof vname);
	   case 471: strcpy(vname, "Quad", sizeof vname);
	   case 472: strcpy(vname, "Coastguard", sizeof vname);
	   case 473: strcpy(vname, "Dinghy", sizeof vname);
	   case 474: strcpy(vname, "Hermes", sizeof vname);
	   case 475: strcpy(vname, "Sabre", sizeof vname);
	   case 476: strcpy(vname, "Rustler", sizeof vname);
	   case 477: strcpy(vname, "ZR-350", sizeof vname);
	   case 478: strcpy(vname, "Walton", sizeof vname);
	   case 479: strcpy(vname, "Regina", sizeof vname);
	   case 480: strcpy(vname, "Comet", sizeof vname);
	   case 481: strcpy(vname, "BMX", sizeof vname);
	   case 482: strcpy(vname, "Burrito", sizeof vname);
	   case 483: strcpy(vname, "Camper", sizeof vname);
	   case 484: strcpy(vname, "Marquis", sizeof vname);
	   case 485: strcpy(vname, "Baggage", sizeof vname);
	   case 486: strcpy(vname, "Dozer", sizeof vname);
	   case 487: strcpy(vname, "Maverick", sizeof vname);
	   case 488: strcpy(vname, "SAN News Maverick", sizeof vname);
	   case 489: strcpy(vname, "Rancher", sizeof vname);
	   case 490: strcpy(vname, "FBI Rancher", sizeof vname);
	   case 491: strcpy(vname, "Virgo", sizeof vname);
	   case 492: strcpy(vname, "Greenwood", sizeof vname);
	   case 493: strcpy(vname, "Jetmax", sizeof vname);
	   case 494: strcpy(vname, "Hotring Racer", sizeof vname);
	   case 495: strcpy(vname, "Sandking", sizeof vname);
	   case 496: strcpy(vname, "Blista Compact", sizeof vname);
	   case 497: strcpy(vname, "Police Maverick", sizeof vname);
	   case 498: strcpy(vname, "Boxville", sizeof vname);
	   case 499: strcpy(vname, "Benson", sizeof vname);
	   case 500: strcpy(vname, "Mesa", sizeof vname);
	   case 501: strcpy(vname, "RC Goblin", sizeof vname);
	   case 502: strcpy(vname, "Hotring Racer", sizeof vname);
	   case 503: strcpy(vname, "Hotring Racer", sizeof vname);
	   case 504: strcpy(vname, "Bloodring Banger", sizeof vname);
	   case 505: strcpy(vname, "Rancher", sizeof vname);
	   case 506: strcpy(vname, "Super GT", sizeof vname);
	   case 507: strcpy(vname, "Elegant", sizeof vname);
	   case 508: strcpy(vname, "Journey", sizeof vname);
	   case 509: strcpy(vname, "Bike", sizeof vname);
	   case 510: strcpy(vname, "Mountain Bike", sizeof vname);
	   case 511: strcpy(vname, "Beagle", sizeof vname);
	   case 512: strcpy(vname, "Cropduster", sizeof vname);
	   case 513: strcpy(vname, "Stuntplane", sizeof vname);
	   case 514: strcpy(vname, "Tanker", sizeof vname);
	   case 515: strcpy(vname, "Roadtrain", sizeof vname);
	   case 516: strcpy(vname, "Nebula", sizeof vname);
	   case 517: strcpy(vname, "Majestic", sizeof vname);
	   case 518: strcpy(vname, "Buccaneer", sizeof vname);
	   case 519: strcpy(vname, "Shamal", sizeof vname);
	   case 520: strcpy(vname, "Hydra", sizeof vname);
	   case 521: strcpy(vname, "FCR-900", sizeof vname);
	   case 522: strcpy(vname, "NRG-500", sizeof vname);
	   case 523: strcpy(vname, "HPV1000", sizeof vname);
	   case 524: strcpy(vname, "Cement Truck", sizeof vname);
	   case 525: strcpy(vname, "Towtruck", sizeof vname);
	   case 526: strcpy(vname, "Fortune", sizeof vname);
	   case 527: strcpy(vname, "Cadrona", sizeof vname);
	   case 528: strcpy(vname, "FBI Truck", sizeof vname);
	   case 529: strcpy(vname, "Willard", sizeof vname);
	   case 530: strcpy(vname, "Forklift", sizeof vname);
	   case 531: strcpy(vname, "Tractor", sizeof vname);
	   case 532: strcpy(vname, "Combine Harvester", sizeof vname);
	   case 533: strcpy(vname, "Feltzer", sizeof vname);
	   case 534: strcpy(vname, "Remington", sizeof vname);
	   case 535: strcpy(vname, "Slamvan", sizeof vname);
	   case 536: strcpy(vname, "Blade", sizeof vname);
	   case 537: strcpy(vname, "Freight", sizeof vname);
	   case 538: strcpy(vname, "Brownstreak", sizeof vname);
	   case 539: strcpy(vname, "Vortex", sizeof vname);
	   case 540: strcpy(vname, "Vincent", sizeof vname);
	   case 541: strcpy(vname, "Bullet", sizeof vname);
	   case 542: strcpy(vname, "Clover", sizeof vname);
	   case 543: strcpy(vname, "Sadler", sizeof vname);
	   case 544: strcpy(vname, "Firetruck LA", sizeof vname);
	   case 545: strcpy(vname, "Hustler", sizeof vname);
	   case 546: strcpy(vname, "Intruder", sizeof vname);
	   case 547: strcpy(vname, "Primo", sizeof vname);
	   case 548: strcpy(vname, "Cargobob", sizeof vname);
	   case 549: strcpy(vname, "Tampa", sizeof vname);
	   case 550: strcpy(vname, "Sunrise", sizeof vname);
	   case 551: strcpy(vname, "Merit", sizeof vname);
	   case 552: strcpy(vname, "Utility Van", sizeof vname);
	   case 553: strcpy(vname, "Nevada", sizeof vname);
	   case 554: strcpy(vname, "Yosemite", sizeof vname);
	   case 555: strcpy(vname, "Windsor", sizeof vname);
	   case 556: strcpy(vname, "Monster A", sizeof vname);
	   case 557: strcpy(vname, "Monster B", sizeof vname);
	   case 558: strcpy(vname, "Uranus", sizeof vname);
	   case 559: strcpy(vname, "Jester", sizeof vname);
	   case 560: strcpy(vname, "Sultan", sizeof vname);
	   case 561: strcpy(vname, "Stratum", sizeof vname);
	   case 562: strcpy(vname, "Elegy", sizeof vname);
	   case 563: strcpy(vname, "Raindance", sizeof vname);
	   case 564: strcpy(vname, "RC Tiger", sizeof vname);
	   case 565: strcpy(vname, "Flash", sizeof vname);
	   case 566: strcpy(vname, "Tahoma", sizeof vname);
	   case 567: strcpy(vname, "Savanna", sizeof vname);
	   case 568: strcpy(vname, "Bandito", sizeof vname);
	   case 569: strcpy(vname, "Freight Flat Trailer", sizeof vname);
	   case 570: strcpy(vname, "Streak Trailer", sizeof vname);
	   case 571: strcpy(vname, "Kart", sizeof vname);
	   case 572: strcpy(vname, "Mower", sizeof vname);
	   case 573: strcpy(vname, "Dune", sizeof vname);
	   case 574: strcpy(vname, "Sweeper", sizeof vname);
	   case 575: strcpy(vname, "Broadway", sizeof vname);
	   case 576: strcpy(vname, "Tornado", sizeof vname);
	   case 577: strcpy(vname, "AT400", sizeof vname);
	   case 578: strcpy(vname, "DFT-30", sizeof vname);
	   case 579: strcpy(vname, "Huntley", sizeof vname);
	   case 580: strcpy(vname, "Stafford", sizeof vname);
	   case 581: strcpy(vname, "BF-400", sizeof vname);
	   case 582: strcpy(vname, "Newsvan", sizeof vname);
	   case 583: strcpy(vname, "Tug", sizeof vname);
	   case 584: strcpy(vname, "Petrol Trailer", sizeof vname);
	   case 585: strcpy(vname, "Emperor", sizeof vname);
	   case 586: strcpy(vname, "Wayfarer", sizeof vname);
	   case 587: strcpy(vname, "Euros", sizeof vname);
	   case 588: strcpy(vname, "Hotdog", sizeof vname);
	   case 589: strcpy(vname, "Club", sizeof vname);
	   case 590: strcpy(vname, "Freight Box Trailer", sizeof vname);
	   case 591: strcpy(vname, "Article Trailer 3", sizeof vname);
	   case 592: strcpy(vname, "Andromada", sizeof vname);
	   case 593: strcpy(vname, "Dodo", sizeof vname);
	   case 594: strcpy(vname, "RC Cam", sizeof vname);
	   case 595: strcpy(vname, "Launch", sizeof vname);
	   case 596: strcpy(vname, "Police Car (LSPD)", sizeof vname);
	   case 597: strcpy(vname, "Police Car (SFPD)", sizeof vname);
	   case 598: strcpy(vname, "Police Car (LVPD)", sizeof vname);
	   case 599: strcpy(vname, "Police Ranger", sizeof vname);
	   case 600: strcpy(vname, "Picador", sizeof vname);
	   case 601: strcpy(vname, "S.W.A.T.", sizeof vname);
	   case 602: strcpy(vname, "Alpha", sizeof vname);
	   case 603: strcpy(vname, "Phoenix", sizeof vname);
	   case 604: strcpy(vname, "Glendale Shit", sizeof vname);
	   case 605: strcpy(vname, "Sadler Shit", sizeof vname);
	   case 606: strcpy(vname, "Baggage Trailer A", sizeof vname);
	   case 607: strcpy(vname, "Baggage Trailer B", sizeof vname);
	   case 608: strcpy(vname, "Tug Stairs Trailer", sizeof vname);
	   case 609: strcpy(vname, "Boxville", sizeof vname);
	   case 610: strcpy(vname, "Farm Trailer", sizeof vname);
	   case 611: strcpy(vname, "Utility Trailer", sizeof vname);
	}
	return vname;
}

stock DatesTime(Start[], End[], &offest)
{
    new
		dtmp[128],
		idx1,
		idx2,
		StartDay,
		StartMonth,
		StartYear,
		EndDay,
		EndMonth,
		EndYear,
		init_date,
		dest_date
		;
    dtmp = strtok(Start, idx1);
    StartDay = strval(dtmp);
    dtmp = strtok(Start, idx1);
    StartMonth = strval(dtmp);
    dtmp = strtok(Start, idx1);
    StartYear = strval(dtmp);
    dtmp = strtok(End, idx2);
    EndDay = strval(dtmp);
    dtmp = strtok(End, idx2);
    EndMonth = strval(dtmp);
    dtmp = strtok(End, idx2);
    EndYear = strval(dtmp);
    init_date = mktime(12,0,0,StartDay,StartMonth,StartYear);
    dest_date = mktime(12,0,0,EndDay,EndMonth,EndYear);
    offest = dest_date - init_date;
    offest = floatround(offest/60/60/24, floatround_floor);
    return true;
}

stock mktime(hour, minute, second, day, month, year)
{
	new timestamp2;
	timestamp2 = second + (minute * 60) + (hour * 3600);
	new days_of_month[12];
	if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )
		days_of_month = {31,29,31,30,31,30,31,31,30,31,30,31};
	else
		days_of_month = {31,28,31,30,31,30,31,31,30,31,30,31};
	new days_this_year = 0;
	days_this_year = day;
	if(month > 1) for(new i=0; i<month-1;i++)
		days_this_year += days_of_month[i];
	timestamp2 += days_this_year * 86400;
	for(new j=1970;j<year;j++)
	{
		timestamp2 += 31536000;
		if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )  timestamp2 += 86400;
	}
	return timestamp2;
}

stock strtok(str[], &index, array[20] = ' ', dilimiter[2] = '.') // _BigMan_ קרדיט ל
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
