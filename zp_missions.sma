#include<amxmodx>
#include<fun>
#include<zombieplague>

new g_ChosenMission[33]; // 0 - no mission, 100 - mission for round complete
new g_InfectionCounter[33];
new g_DamageDealt[33];
new g_GrenadesThrown[33];
new g_ZombieKills[33];
new g_ZMissions[2][3] =
{
	//Mission ID | Humans to Infect | AP Reward
	{1, 2, 10}, {3, 4, 30}
};
new g_HMissions[4][3] =
{
	//Mission ID | Damage to deal | AP Reward
	{2, 5000, 10}, {4, 10000, 20},
	//Mission ID | Grenades to throw | AP Reward
	{6, 6, 25},
	//Mission ID | Kills required | Armor Reward
	{8, 2, 50}
};
//you can change requirements/rewards here

public plugin_init()
{
	register_plugin("ZP Missions", "1.0", "b6gd")
	register_clcmd("say /missions", "cmd_missions");
	register_clcmd("say /mission", "cmd_missions");
	register_clcmd("say_team /missions", "cmd_missions");
	register_clcmd("say_team /mission", "cmd_missions");
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
}

public cmd_missions(id)
{
	if(!is_user_alive(id))
	{
		client_print_color(id, print_team_red, "^4[ZP Missions] ^1You are not alive!");
		return PLUGIN_HANDLED;
	}
	if(zp_has_round_started() != 1)
	{
		client_print_color(id, print_team_red, "^4[ZP Missions] ^3Round has not started yet!");
		return PLUGIN_HANDLED;
	}
	new team[16];
	get_user_team(id, team, 16);
	if(equali(team, "TERRORIST", 16))
	{
		zombie_missions_menu(id);
	}
	if(equali(team, "CT", 16))
	{
		human_missions_menu(id);
	}
	return PLUGIN_HANDLED;
}

/*
	Zombie Missions
*/
public zombie_missions_menu(id)
{
	new menu = menu_create("\w[\yM\w] - Mission :: [\yR\w] - Reward", "zombie_menu_handler");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	new str[64];
	format(str, 64, "\w[\yM\w] Infect %d humans [\yR\w]\r %d AP", g_ZMissions[0][1], g_ZMissions[0][2]);
	menu_additem(menu, str);
	format(str, 64, "\w[\yM\w] Infect %d humans [\yR\w]\r %d AP", g_ZMissions[1][1], g_ZMissions[1][2]);
	menu_additem(menu, str);
	menu_display(id, menu, 0);
}

public zombie_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(g_ChosenMission[id] == 100)
	{
		client_print_color(id, print_team_red, "^4[ZP Missions] ^1You can take only one mission per round.");
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(g_ChosenMission[id] != 0)
	{
		client_print_color(id, print_team_red, "^4[ZP Missions] ^1You already have a mission.");
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		case 0:
		{
			g_ChosenMission[id] = g_ZMissions[0][0];
			client_print_color(id, print_team_red, "^4[ZP Missions] ^1[^3Zombie^1] Infect %d humans.", g_ZMissions[0][1]);
		}
		case 1:
		{
			g_ChosenMission[id] = g_ZMissions[1][0];
			client_print_color(id, print_team_red, "^4[ZP Missions] ^1[^3Zombie^1] Infect %d humans.", g_ZMissions[1][1]);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

/*
	Human Missions
*/

public human_missions_menu(id)
{
	new menu = menu_create("\w[\yM\w] - Mission :: [\yR\w] - Reward", "human_menu_handler");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	new str[64];
	format(str, 64, "\w[\yM\w] Deal %d damage to Zombies [\yR\w]\r %d AP", g_HMissions[0][1], g_HMissions[0][2]); 
	menu_additem(menu, str);
	format(str, 64, "\w[\yM\w] Deal %d damage to Zombies [\yR\w]\r %d AP", g_HMissions[1][1], g_HMissions[1][2]); 
	menu_additem(menu, str);
	format(str, 64, "\w[\yM\w] Throw %d grenades [\yR\w]\r %d AP", g_HMissions[2][1], g_HMissions[2][2]); 
	menu_additem(menu, str);
	format(str, 64, "\w[\yM\w] Kill %d Zombies [\yR\w]\r %d Armor", g_HMissions[3][1], g_HMissions[3][2]); 
	menu_additem(menu, str);
	menu_display(id, menu, 0);
}

public human_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(g_ChosenMission[id] == 100)
	{
		client_print_color(id, print_team_blue, "^4[ZP Missions] ^1You can take only one mission per game.");
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(g_ChosenMission[id] != 0)
	{
		client_print_color(id, print_team_blue, "^4[ZP Missions] ^1You already have a mission.");
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		case 0:
		{
			g_ChosenMission[id] = g_HMissions[0][0];
			client_print_color(id, print_team_blue, "^4[ZP Missions] ^1[^3Human^1] Deal %d damage to Zombies.", g_HMissions[0][1]);
		}
		case 1:
		{
			g_ChosenMission[id] = g_HMissions[1][0];
			client_print_color(id, print_team_blue, "^4[ZP Missions] ^1[^3Human^1] Deal %d damage to Zombies.", g_HMissions[1][1]);
		}
		case 2:
		{
			g_ChosenMission[id] = g_HMissions[2][0];
			client_print_color(id, print_team_blue, "^4[ZP Missions] ^1[^3Human^1] Throw %d grenades.", g_HMissions[2][1]);
		}
		case 3:
		{
			g_ChosenMission[id] = g_HMissions[3][0];
			client_print_color(id, print_team_blue, "^4[ZP Missions] ^1[^3Human^1] Kill %d Zombies.", g_HMissions[3][1]);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

/*
	Rewards manager
*/

public give_ammo_reward(id, amount)
{
	client_print_color(id, print_team_blue, "^4[ZP Missions] ^1Mission complete! Reward: ^3 %d AP", amount);
	new ammo = zp_get_user_ammo_packs(id) + amount;
	zp_set_user_ammo_packs(id, ammo);
	g_ChosenMission[id] = 100;
}

public give_armor_reward(id, amount)
{
	client_print_color(id, print_team_blue, "^4[ZP Missions] ^1Mission complete! Reward: ^3 %d Armor", amount);
	new armor = get_user_armor(id) + amount;
	set_user_armor(id, armor);
	g_ChosenMission[id] = 100;
}

public progress_check(id)
{
	new mission = g_ChosenMission[id];
	
	if(mission == g_ZMissions[0][0])
	{
		if(g_InfectionCounter[id] >= g_ZMissions[0][1])
		{
			give_ammo_reward(id, g_ZMissions[0][2]);
		}
	}
	else if(mission == g_ZMissions[1][0])
	{
		if(g_InfectionCounter[id] >= g_ZMissions[1][1])
		{
			give_ammo_reward(id, g_ZMissions[1][2]);
		}
	}
	else if(mission == g_HMissions[0][0])
	{
		if(g_DamageDealt[id] >= g_HMissions[0][1])
		{
			give_ammo_reward(id, g_HMissions[0][2]);
		}
	}
	else if(mission == g_HMissions[1][0])
	{
		if(g_DamageDealt[id] >= g_HMissions[1][1])
		{
			give_ammo_reward(id, g_HMissions[1][2]);
		}
	}
	else if(mission == g_HMissions[2][0])
	{
		if(g_GrenadesThrown[id] >= g_HMissions[2][1])
		{
			give_ammo_reward(id, g_HMissions[2][2]);
		}
	}
	else if(mission == g_HMissions[3][0])
	{
		if(g_ZombieKills[id] >= g_HMissions[3][1])
		{
			give_armor_reward(id, g_HMissions[3][2]);
		}
	}
	return PLUGIN_CONTINUE;
}

/*
	Events
*/

public zp_user_infected_post(id, infector, nemesis)
{
	if(infector == 0)
	{
		return PLUGIN_CONTINUE;
	}
	if(g_ChosenMission[infector] == g_ZMissions[0][0] || g_ChosenMission[infector] == g_ZMissions[1][0])
	{
		++g_InfectionCounter[infector];
		progress_check(infector);
	}
	return PLUGIN_CONTINUE;
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
	if(attacker == 0 || attacker == victim)
	{
		return PLUGIN_CONTINUE;
	}
	if(get_user_team(attacker) == 2 && (g_ChosenMission[attacker] == g_HMissions[0][0] || g_ChosenMission[attacker] == g_HMissions[1][0]))
	{
		g_DamageDealt[attacker] += damage;
		progress_check(attacker);
	}
	return PLUGIN_CONTINUE;
}

public grenade_throw(id, greindex, wid)
{
	if(id == 0)
	{
		return PLUGIN_CONTINUE;
	}
	if(get_user_team(id) == 2 && g_ChosenMission[id] == g_HMissions[2][0])
	{
		++g_GrenadesThrown[id];
		progress_check(id);
	}
	return PLUGIN_CONTINUE;
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if(!is_user_connected(killer) || killer == victim)
	{
		return PLUGIN_CONTINUE;
	}
	if(get_user_team(killer) == 2 && g_ChosenMission[killer] == g_HMissions[3][0])
	{
		++g_ZombieKills[killer];
		progress_check(killer);
	}
	return PLUGIN_CONTINUE;
}

/*
	Cleanup functions
*/

public reset_counters(id)
{
	g_ChosenMission[id] = 0;
	g_DamageDealt[id] = 0;
	g_GrenadesThrown[id] = 0;
	g_InfectionCounter[id] = 0;
	g_ZombieKills[id] = 0;
}

public event_round_start()
{
	new i;
	for(i=0; i<33; ++i)
	{
		reset_counters(i);
	}
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
	reset_counters(id);
}