#include <sourcemod>
#include <adminmenu>
#include <tf2_stocks>
#include <cstrike>

#pragma tabsize 4

bool 
	WeapDick[MAXPLAYERS+1],
	DickMdl[MAXPLAYERS+1],
	CockCh[MAXPLAYERS+1],
	CockSnd[MAXPLAYERS+1],
	DisDmg[MAXPLAYERS+1],
	MtlDmg[MAXPLAYERS+1],
	BanTimer[MAXPLAYERS+1];

Menu hMenu;

char czDownloadPaths[][] = {
    "materials/models/player/kaesar/chickenleet/wings.vmt",
    "materials/models/player/kaesar/chickenleet/t_leet_glass.vmt",
    "materials/models/player/kaesar/chickenleet/t_leet.vmt",
    "materials/models/player/kaesar/chickenleet/body.vmt",
    "models/player/custom_player/kaesar/chickenleet/chickenleet.mdl",
    "models/player/custom_player/kaesar/chickenleet/chickenleet.dx90.vtx",
    "models/player/custom_player/kaesar/chickenleet/chickenleet.vvd",
    "models/player/custom_player/kaesar/chickenleet/chickenleet.phy",
    "materials/models/player/kaesar/chickenleet/wings_n.vtf",
    "materials/models/player/kaesar/chickenleet/t_leet_normal.vtf",
    "materials/models/player/kaesar/chickenleet/t_leet_glass.vtf",
    "materials/models/player/kaesar/chickenleet/t_leet.vtf",
    "materials/models/player/kaesar/chickenleet/wings.vtf",
    "materials/models/player/kaesar/chickenleet/body_n.vtf",
    "materials/models/player/kaesar/chickenleet/body.vtf"
}

public void OnPluginStart()
{
/*     HookEvent("player_hurt", Event_PlayerHurt);
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);
 */
    RegAdminCmd("helloban", CMD_FuckBan, ADMFLAG_ROOT);
}

/* public void OnClientPostAdminCheck()
{

}

public void OnClientDisconnect()
{

}
 */
public void OnMapStart()
{
    for(int i = 0;i<=sizeof(czDownloadPaths);i++)
    {
        if(StrContains(czDownloadPaths[i],".mdl"))
        {
            PrecacheModel(czDownloadPaths[i], true);
        }
        else if(StrContains(czDownloadPaths[i],".mp3")||StrContains(czDownloadPaths[i],".wav"))
        {
            char buff[PLATFORM_MAX_PATH];
            ReplaceStringEx(czDownloadPaths[i], sizeof(buff), "sound/", "*/")
            PrecacheSound(czDownloadPaths[i], true)
        }
    }
}

public void OnMapEnd()
{

}

public Action CMD_FuckBan(int client, int args)
{
	OnCreateMainMenu(client, true)
}

public void OnCreateMainMenu(client, bool withTargets)
{
    hMenu = new Menu(mMenu_Handler);
	if(withTargets) AddTargetsToMenu(hMenu,0,true);
	
	else
	{
		hMenu.AddItem("item1","WeaponDick");
		hMenu.AddItem("item2","DickModel");
		hMenu.AddItem("item3","CockChat");
		hMenu.AddItem("item4","CockSound");
		hMenu.AddItem("item5","DisableDamage");
		hMenu.AddItem("item6","MutualDamage");
		hMenu.AddItem("item7","BanTimer");
	}
    hMenu.ExitBackButton = true;
    hMenu.ExitButton = true;
    hMenu.Display(client, 0);
}

public int mMenu_Handler(Menu menu, MenuAction action, int client, int item)
{
	int target;
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
		return;
	}

	if(action == MenuAction_Select)
	{
		char userid[16];
		GetMenuItem(menu, option, userid, sizeof(userid));
		int target = GetClientOfUserId(StringToInt(userid))
		OnCreateMainMenu(client, false);
		switch(item)
		{
			case 1: WeaponDickAction(target);
			case 2: DickModel(target);
			case 3: CockChat(target);
			case 4: CockSound(target);
			case 5: DisableDamage(target);
			case 6: MutualDamage(target);
			case 7: BanTimer(target);
		}
/* 		menu.AddItem("item1","WeaponDick");
		menu.AddItem("item2","DickModel");
		menu.AddItem("item3","CockChat");
		menu.AddItem("item4","CockSound");
		menu.AddItem("item5","DisableDamage");
		menu.AddItem("item6","MutualDamage");
		menu.AddItem("item7","BanTimer"); */
	}
}

public Action WeaponDickAction(client)
{
	if(!IsFakeClient(client) && IsClientInGame(client) && WeapDick[client]!=true)
	{
		TF2_RemoveAllWeapons(client);
		int WeaponINDEX = CS_WeaponIDToItemDefIndex(CSWeapon_KNIFE)
		EquipPlayerWeapon(client,WeaponINDEX);
		WeapDick[client]=true;
	}
}

public Action DickModel(client)
{
	if(DickMdl[client]!=true && !IsFakeClient(client) && IsClientInGame(client))
	{
		SetEntityModel(client,"/models");
		DickMdl=true;
	}
}

public Action CockChat(client)
{
	
}

public Action CockSound(client)
{
	
}

public Action DisableDamage(client)
{
	
}

public Action MutualDamage(client)
{
	
}

public Action BanTimer(client)
{
	
}

/* public Action Event_PlayerHurt(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{

}

public Action Event_RoundStart(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{

}

public Action Event_RoundEnd(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{

}

public Action Event_PlayerSpawn(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{

}

public Action Event_PlayerDeath(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{

} */