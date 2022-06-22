#include <sourcemod>
#include <adminmenu>
#include <tf2_stocks>
#include <cstrike>

#pragma tabsize 4

bool 
	bWeapDick[MAXPLAYERS+1],
	bDickMdl[MAXPLAYERS+1],
	bCockCh[MAXPLAYERS+1],
	bCockSnd[MAXPLAYERS+1],
	bDisDmg[MAXPLAYERS+1],
	bMtlDmg[MAXPLAYERS+1],
	bBanTimer[MAXPLAYERS+1];

char czCockMsg[][] = {
	"Ко-Ко-Ко",
	"Я петушара"
}

char czDefaultModelPlayer[MAXPLAYERS+1][PLATFORM_MAX_PATH];

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
    "materials/models/player/kaesar/chickenleet/body.vtf",
	"models/weapons/w_knife_default_ct_dropped.mdl",
	"models/weapons/w_knife_default_ct_dropped.dx90.vtx",
	"models/weapons/w_knife_default_ct_dropped.vvd",
	"models/weapons/w_knife_default_ct_dropped.phy",
	"models/weapons/w_knife_default_ct.mdl",
	"models/weapons/w_knife_default_ct.dx90.vtx",
	"models/weapons/w_knife_default_ct.vvd",
	"models/weapons/w_knife_default_t_dropped.mdl",
	"models/weapons/w_knife_default_t_dropped.dx90.vtx",
	"models/weapons/w_knife_default_t_dropped.vvd",
	"models/weapons/w_knife_default_t_dropped.phy",
	"models/weapons/w_knife_default_t.mdl",
	"models/weapons/w_knife_default_t.dx90.vtx",
	"models/weapons/w_knife_default_t.vvd",
	"models/weapons/w_knife_default_t.phy",
	"models/weapons/v_knife_default_ct.mdl",
	"models/weapons/v_knife_default_t.mdl",
	"models/weapons/v_knife_default_ct.dx90.vtx",
	"models/weapons/v_knife_default_t.dx90.vtx",
	"models/weapons/v_knife_default_ct.vvd",
	"models/weapons/v_knife_default_t.vvd",
	"materials/models/mikeymack/horsecock/horsecock_d4.vmt",
	"materials/models/mikeymack/horsecock/horsecock_d4.vtf",
	"materials/models/mikeymack/horsecock/horsecock_n.vtf",
	"materials/models/mikeymack/horsecock/phong.vtf",
	"materials/models/mikeymack/horsecock/detail_skin.vtf",
	"materials/models/mikeymack/horsecock/lightwarp.vtf"
}

public void OnPluginStart()
{
    HookEvent("player_hurt", Event_PlayerHurt);
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);
	AddCommandListener(SayCB,"say");

    RegAdminCmd("helloban", CMD_FuckBan, ADMFLAG_ROOT);
}

public void OnClientPostAdminCheck()
{

}

public void OnClientDisconnect()
{

}

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

public Action CMD_FuckBan(client, int args)
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

public int mMenu_Handler(Menu menu, MenuAction action, client, int item)
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
		GetMenuItem(menu, item, userid, sizeof(userid));
		target = GetClientOfUserId(StringToInt(userid))
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
	}
}

public Action SayCB(int client, const char[] command, int argc)
{
	if(bCockCh[client]==true)
	{
		char cockchBuff[256];
		FormatEx(cockchBuff, sizeof(cockchBuff), "%s", czCockMsg[GetRandomInt(0,1)])
		PrintToChatAll(cockchBuff);
	}
}

public Action WeaponDickAction(client)
{
	if(!IsFakeClient(client) && IsClientInGame(client) && bWeapDick[client]!=true)
	{
		TF2_RemoveAllWeapons(client);
		int WeaponINDEX = CS_WeaponIDToItemDefIndex(CSWeapon_KNIFE)
		EquipPlayerWeapon(client,WeaponINDEX);
		bWeapDick[client]=true;
	}
}

public Action DickModel(client)
{
	GetClientModel(client, czDefaultModelPlayer[client], sizeof(czDefaultModelPlayer));
	if(!IsFakeClient(client) && IsClientInGame(client))
	{
		if(bDickMdl[client]!=true)
		{
			SetEntityModel(client,czDownloadPaths[4][PLATFORM_MAX_PATH]);
			bDickMdl[client]=true;
		}
		else
		{
			bDickMdl[client]=false;
			SetEntityModel(client,czDefaultModelPlayer[client])
		}
	}
}

public Action CockChat(client)
{
	bCockCh[client]=true;
	if(bCockCh[client]==true)
	{
		bCockCh[client]=false;
	}
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

public Action Event_PlayerHurt(Event hEvent, const char[] sEvent, bool bDontBroadcast)
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

}
