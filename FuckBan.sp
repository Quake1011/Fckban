#include <sourcemod>
#include <adminmenu>
#include <sdkhooks>
#include <tf2_stocks>
#include <materialadmin>
#include <cstrike>

#pragma tabsize 4

bool 
	bWeapDick[MAXPLAYERS+1],
	bDickMdl[MAXPLAYERS+1],
	bCockCh[MAXPLAYERS+1],
	bCockSnd[MAXPLAYERS+1],
	bDisDmg[MAXPLAYERS+1],
	bMtlDmg[MAXPLAYERS+1],
	bBanTimer[MAXPLAYERS+1]

Handle ghTimer[MAXPLAYERS+1];

char czCockMsg[][] = {
	"РљРѕ-РљРѕ-РљРѕ",
	"РЇ РїРµС‚СѓС€Р°СЂР°"
}

float dmgEnt[MAXPLAYERS+1];

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
	"materials/models/mikeymack/horsecock/lightwarp.vtf",
	"sound/FuckBan/CockSndDir/cockChat.mp3"
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

public void OnClientDisconnectPre(client)
{
	if(bBanTimer[client])
	{
		CreateTimer(0.0, BanTimerCallBack, client);
	}
}

public void OnMapStart()
{
    for(int i = 0;i<=sizeof(czDownloadPaths);i++)
    {
        if(StrContains(czDownloadPaths[i],".mdl"))
        {
            PrecacheModel(czDownloadPaths[i], true);
        }
        else if(StrContains(czDownloadPaths[i],".mp3") || StrContains(czDownloadPaths[i],".wav"))
        {
            char buff[PLATFORM_MAX_PATH];
            ReplaceStringEx(czDownloadPaths[i], sizeof(buff), "sound/", "*/");
            PrecacheSound(czDownloadPaths[i], true);
        }
    }
}

public Action CMD_FuckBan(client, int args)
{
	OnCreateMainMenu(client, true);
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
	if(bCockCh[client])
	{
		char cockchBuff[256];
		FormatEx(cockchBuff, sizeof(cockchBuff), "%s", czCockMsg[GetRandomInt(0,1)])
		PrintToChatAll(cockchBuff);
	}
}

bool WeaponDickAction(client)
{
	if(!IsFakeClient(client) && IsClientInGame(client) && bWeapDick[client]!=true)
	{
		TF2_RemoveAllWeapons(client);
		int WeaponINDEX = CS_WeaponIDToItemDefIndex(CSWeapon_KNIFE);
		EquipPlayerWeapon(client,WeaponINDEX);
		bWeapDick[client]=true;
	}
}

bool DickModel(client)
{
	GetClientModel(client, czDefaultModelPlayer[client], sizeof(czDefaultModelPlayer));
	if(!IsFakeClient(client) && IsClientInGame(client))
	{
		if(!bDickMdl[client])
		{
			SetEntityModel(client,czDownloadPaths[4][PLATFORM_MAX_PATH]);
			bDickMdl[client] = true;
		}
		else
		{
			SetEntityModel(client,czDefaultModelPlayer[client])
		}
	}
}

bool CockChat(client)
{
	if(bCockCh[client])
	{
		bCockCh[client] = false;
	}
	else bCockCh[client] = true;
}

bool CockSound(client)
{
	if(bCockSnd[client])
	{
		bCockSnd[client] = false;
	}
	else bCockSnd[client] = true;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	float fClientOrig[3];
	GetClientAbsOrigin(client, fClientOrig);
	if(client && IsClientInGame(client))
	{
		if(bCockSnd[client])
		{
			if(buttons & IN_USE || IN_DUCK || IN_ATTACK)
			{
				char buff[PLATFORM_MAX_PATH];
				ReplaceStringEx(czDownloadPaths[sizeof(czDownloadPaths)-1], sizeof(buff), "sound/", "*/");
				EmitAmbientSound(czDownloadPaths[sizeof(czDownloadPaths)-1], fClientOrig, client, SNDLEVEL_HELICOPTER);
			}
		}
	}
	return Plugin_Continue;
}

bool DisableDamage(client)
{
	if(bDisDmg[client])
	{
		bDisDmg[client] = false;
	}
	else bDisDmg[client] = true;
}

bool MutualDamage(client)
{
	if(bMtlDmg[client])
	{
		bMtlDmg[client] = false;
	}
	else bMtlDmg[client] = true;
}

bool BanTimer(client)
{
	if(bBanTimer[client])
	{
		bBanTimer[client] = false;
		KillTimer(ghTimer[client]);
		ghTimer[client] = null;
	}
	else 
	{	
		bBanTimer[client] = true;
		ghTimer[client] = CreateTimer(1800.0, BanTimerCallBack, client);
	}
}

public Action BanTimerCallBack(Handle hTimer, client)
{
	if(ghTimer[client] != INVALID_HANDLE)
	{
		MABanPlayer(2, client, 0, 0, "?Cheater?")
		//MaBanPlayer(0, client, MA_BAN_STEAM, 0, "?Cheater?");
		KillTimer(ghTimer[client]);
		ghTimer[client] = null;
	}
}

public Action Event_PlayerHurt(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	dmgEnt[iAttacker] = GetEntPropFloat(iAttacker, Prop_Send, "m_flDamage");
	int iAttHp = GetEntProp(iAttacker, Prop_Send, "m_iHealth");
	if(bDisDmg[iAttacker])
	{
		if(dmgEnt[iAttacker] > 0.0)
		{
			SetEntPropFloat(iAttacker, Prop_Send, "m_flDamage", 0.0);
		}
		if(bMtlDmg[iAttacker])
		{
			SetEntProp(iAttacker, Prop_Send, "m_iHealth",(iAttHp-10));
		}
	}
	return Plugin_Continue;
}

/* public Action Event_RoundStart(Event hEvent, const char[] sEvent, bool bDontBroadcast)
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