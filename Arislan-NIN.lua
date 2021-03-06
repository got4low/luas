-------------------------------------------------------------------------------------------------------------------
-- (Original: Motenten / Modified: Arislan)
-------------------------------------------------------------------------------------------------------------------

--[[	Custom Features:

		Haste Detection		Detects current magic haste level and equips corresponding engaged set to
							optimize delay reduction (automatic)
		Haste Mode			Toggles between Haste II and Haste I recieved, used by Haste Detection [WinKey-H]
		Capacity Pts. Mode	Capacity Points Mode Toggle [WinKey-C]
		Reive Detection		Automatically equips Reive bonus gear
		Auto. Lockstyle		Automatically locks specified equipset on file load
--]]


-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
	mote_include_version = 2

	-- Load and initialize the include file.
	include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
	state.Buff.Migawari = buffactive.migawari or false
	state.Buff.Doom = buffactive.doom or false
	state.Buff.Yonin = buffactive.Yonin or false
	state.Buff.Innin = buffactive.Innin or false
	state.Buff.Futae = buffactive.Futae or false

	state.HasteMode = M{['description']='Haste Mode', 'Haste II', 'Haste I'}

	determine_haste_group()
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	state.OffenseMode:options('STP', 'Normal', 'LowAcc', 'MidAcc', 'HighAcc', 'Fodder')
	state.WeaponskillMode:options('Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT', 'Evasion')

	state.CP = M(false, "Capacity Points Mode")

	-- Additional local binds
	send_command('bind ^- input /ja "Yonin" <me>')
	send_command('bind ^= input /ja "Innin" <me>')
	if player.sub_job == 'DNC' then
		send_command('bind ^, input /ja "Spectral Jig" <me>')
		send_command('unbind ^.')
	else
		send_command('bind ^, input /nin "Monomi: Ichi" <me>')
		send_command('bind ^. input /ma "Tonko: Ni" <me>')
	end
	send_command('bind ^, input /nin "Monomi: Ichi" <me>')
	send_command('bind ^. input /ma "Tonko: Ni" <me>')
	send_command('bind @h gs c cycle HasteMode')
	send_command('bind @c gs c toggle CP')

--	select_movement_feet()
	select_default_macro_book()
	set_lockstyle()
end

function user_unload()
	send_command('unbind ^-')
	send_command('unbind ^=')
	send_command('unbind ^,')
	send_command('unbind !.')
	send_command('unbind @h')
	send_command('unbind @c')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
--	sets.precast.JA['Mijin Gakure'] = {legs="Mochizuki Hakama"}
--	sets.precast.JA['Futae'] = {legs="Iga Tekko +2"}
--	sets.precast.JA['Sange'] = {legs="Mochizuki Chainmail"}

	sets.precast.Waltz = {
		body="Passion Jacket",
		hands="Slither Gloves +1",
		neck="Phalaina Locket",
		ring1="Asklepian Ring",
		ring2="Valseur's Ring",
		waist="Gishdubar Sash",
		}
		
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast sets for spells
	
	sets.precast.FC = {
		ammo="Sapience Orb", --2
		head=gear.Herc_MAB_head, --7
		body="Taeon Tabard", --9
		hands="Leyline Gloves", --7
		legs="Rawhide Trousers", --5
		feet=gear.Herc_MAB_feet, --2
		neck="Orunmila's Torque", --5
		ear1="Loquacious Earring", --2
		ear2="Etiolation Earring", --1
		ring1="Kishar Ring", --4
		ring2="Weather. Ring", --5(3)
		waist="Ninurta's Sash",
		}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
		ammo="Staunch Tathlum",
		body="Passion Jacket",
		neck="Magoraga Beads",
		ring1="Lebeche Ring",
		waist="Ninurta's Sash",
		})

	sets.precast.RA = {
		head="Aurore Beret +1", --5
		legs="Adhemar Kecks", --9
		}
	   
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		ammo="Seeth. Bomblet +1",
		head="Lilitu Headpiece",
		body="Adhemar Jacket",
		hands=gear.Adhemar_Att_hands,
		legs="Hiza. Hizayoroi +1",
		feet=gear.Herc_TA_feet,
		neck="Fotia Gorget",
		ear1="Moonshade Earring",
		ear2="Ishvara Earring",
		ring1="Ifrit Ring +1",
		ring2="Shukuyu Ring",
		back="Bleating Mantle",
		waist="Fotia Belt",
		} -- default set

	sets.precast.WS.Acc = set_combine(sets.precast.WS, {
		head="Adhemar Bonnet",
		hands=gear.Herc_Acc_hands,
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		})

	sets.precast.WS['Blade: Hi'] = set_combine (sets.precast.WS, {
		ammo="Yetshila",
		ear1="Lugra Earring",
		ear2="Lugra Earring +1",
		ring1="Begrudging Ring",
		ring2="Epona's Ring",
		waist="Windbuffet Belt +1",
		})

	sets.precast.WS['Blade: Ten'] = set_combine (sets.precast.WS, {
		neck="Caro Necklace",
		ear2="Lugra Earring +1",
		waist="Grunfeld Rope",
		})

	sets.precast.WS['Blade: Shun'] = set_combine (sets.precast.WS, {
		legs="Samnuha Tights",
		ear1="Lugra Earring",
		ear2="Lugra Earring +1",
		ring1="Ramuh Ring +1",
		ring2="Ramuh Ring +1",
		})

	sets.precast.WS['Blade: Kamu'] = set_combine (sets.precast.WS, {
		ear1="Lugra Earring",
		ear2="Lugra Earring +1",
		ring1="Ifrit Ring +1",
		ring2="Epona's Ring",
		})

	--------------------------------------
	-- Midcast sets
	--------------------------------------

	sets.midcast.FastRecast = sets.precast.FC

	sets.midcast.SpellInterrupt = {
		ammo="Impatiens", --10
		ear1="Halasz Earring", --5
		ring1="Evanescence Ring", --5
		waist="Ninurta's Sash", --6
		}
		
	-- Specific spells
	sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

	sets.midcast.ElementalNinjutsu = {
		ammo="Seeth. Bomblet +1",
		head=gear.Herc_MAB_head,
		body="Samnuha Coat",
		hands="Leyline Gloves",
		legs=gear.Herc_MAB_legs,
		feet=gear.Herc_MAB_feet,
		neck="Baetyl Pendant",
		ear1="Hecate's Earring",
		ear2="Friomisi Earring",
		ring1="Shiva Ring +1",
		ring2="Shiva Ring +1",
		back="Argocham. Mantle",
		waist="Eschan Stone",
		}

--	sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.Ninjutsu, {})

--	sets.midcast.NinjutsuDebuff = {}

--	sets.midcast.NinjutsuBuff = {}

--	sets.midcast.RA = {}

	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------
	
	-- Resting sets
--	sets.resting = {}
	
	-- Idle sets
	sets.idle = {
		ammo="Ginsen",
		head="Dampening Tam",
		body="Hiza. Haramaki +1",
		hands=gear.Herc_TA_hands,
		legs="Samnuha Tights",
		feet="Danzo Sune-ate",
		neck="Sanctity Necklace",
		ear1="Genmei Earring",
		ear2="Infused Earring",
		ring1="Paguroidea Ring",
		ring2="Sheltered Ring",
		back="Solemnity Cape",
		waist="Flume Belt +1",
		}

	sets.idle.DT = set_combine (sets.idle, {
		ammo="Staunch Tathlum", --2/2
		head=gear.Herc_DT_head, --3/3
		hands=gear.Herc_DT_hands, --6/4
		feet="Amm Greaves", --3/3
		neck="Loricate Torque +1", --6/6
		ear1="Genmei Earring", --2/0
		ring1="Gelatinous Ring +1", --7/(-1)
		ring2="Defending Ring", --10/10
		back="Solemnity Cape", --4/4
		waist="Flume Belt +1", --4/0
		})

	sets.idle.Town = set_combine(sets.idle, {
		neck="Combatant's Torque",
		ear1="Cessance Earring",
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		waist="Windbuffet Belt +1",
		})
	
	sets.idle.Weak = sets.idle.DT
	
	-- Defense sets
	sets.defense.PDT = sets.idle.DT
	sets.defense.MDT = sets.idle.DT

	sets.Kiting = {feet="Danzo sune-ate"}
	
--	sets.DayMovement = {feet="Danzo sune-ate"}
--	sets.NightMovement = {feet="Ninja Kyahan"}


	--------------------------------------
	-- Engaged sets
	--------------------------------------

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion

	-- * NIN Native DW Trait: 35% DW
	
	-- No Magic Haste (74% DW to cap)	
	sets.engaged = {
		ammo="Ginsen",
		head="Dampening Tam",
		body="Adhemar Jacket", --5
		hands="Floral Gauntlets", --5
		legs="Samnuha Tights",
		feet=gear.Taeon_DW_feet, --9
		neck="Erudit. Necklace",
		ear1="Eabani Earring", --4
		ear2="Suppanomimi", --5
		ring1="Petrov Ring",
		ring2="Epona's Ring",
		back="Bleating Mantle",
		waist="Patentia Sash", --5
		} -- 33%

	sets.engaged.LowAcc = set_combine(sets.engaged, {
		ammo="Falcon Eye",
		hands=gear.Herc_TA_hands,
		neck="Combatant's Torque",
		ring1="Chirich Ring",
		})

	sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {
		hands=gear.Herc_Acc_hands,
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		waist="Kentarch Belt +1",
		})

	sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear1="Cessance Earring",
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		waist="Olseni Belt",
		})

	sets.engaged.STP = set_combine(sets.engaged, {
		ear1="Dedition Earring",
		ear2="Telos Earring",
		ring1="Petrov Ring",
		waist="Kentarch Belt +1",
		})

	-- 15% Magic Haste (67% DW to cap)
	sets.engaged.LowHaste = {
		ammo="Ginsen",
		head="Dampening Tam",
		body="Adhemar Jacket", --5
		hands="Floral Gauntlets", --5
		legs="Samnuha Tights",
		feet=gear.Taeon_DW_feet, --9
		neck="Erudit. Necklace",
		ear1="Eabani Earring", --4
		ear2="Suppanomimi", --5
		ring1="Petrov Ring",
		ring2="Epona's Ring",
		back="Bleating Mantle",
		waist="Patentia Sash", --5
		} -- 33%

	sets.engaged.LowHaste.LowAcc = set_combine(sets.engaged.LowHaste, {
		ammo="Falcon Eye",
		hands=gear.Herc_TA_hands,
		neck="Combatant's Torque",
		ring1="Chirich Ring",
		})

	sets.engaged.LowHaste.MidAcc = set_combine(sets.engaged.LowHaste.LowAcc, {
		hands=gear.Herc_Acc_hands,
		feet=gear.Herc_TA_feet,
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		waist="Kentarch Belt +1",
		})

	sets.engaged.LowHaste.HighAcc = set_combine(sets.engaged.LowHaste.MidAcc, {
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear1="Cessance Earring",
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		waist="Olseni Belt",
		})

	sets.engaged.LowHaste.STP = set_combine(sets.engaged.LowHaste, {
		ear1="Dedition Earring",
		ear2="Telos Earring",
		ring1="Petrov Ring",
		waist="Kentarch Belt +1",
		})

	-- 30% Magic Haste (56% DW to cap)
	sets.engaged.MidHaste = {
		ammo="Ginsen",
		head="Dampening Tam",
		body="Adhemar Jacket", --5
		hands=gear.Adhemar_Att_hands,
		legs="Samnuha Tights",
		feet=gear.Herc_TA_feet,
		neck="Erudit. Necklace",
		ear1="Eabani Earring", --4
		ear2="Suppanomimi", --5
		ring1="Petrov Ring",
		ring2="Epona's Ring",
		back="Bleating Mantle",
		waist="Patentia Sash", --5
		} -- 19%

	sets.engaged.MidHaste.LowAcc = set_combine(sets.engaged.MidHaste, {
		ammo="Falcon Eye",
		hands=gear.Herc_TA_hands,
		neck="Combatant's Torque",
		ring1="Chirich Ring",
		})

	sets.engaged.MidHaste.MidAcc = set_combine(sets.engaged.MidHaste.LowAcc, {
		hands=gear.Herc_Acc_hands,
		feet=gear.Herc_TA_feet,
		ear1="Cessance Earring",
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		waist="Kentarch Belt +1",
		})

	sets.engaged.MidHaste.HighAcc = set_combine(sets.engaged.MidHaste.MidAcc, {
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		waist="Olseni Belt",
		})

	sets.engaged.MidHaste.STP = set_combine(sets.engaged.MidHaste, {
		ear1="Dedition Earring",
		ear2="Telos Earring",
		ring1="Petrov Ring",
		waist="Kentarch Belt +1",
		})

	-- 35% Magic Haste (51% DW to cap)
	sets.engaged.HighHaste = {
		ammo="Ginsen",
		head="Dampening Tam",
		body="Adhemar Jacket", --5
		hands=gear.Adhemar_Att_hands,
		legs="Samnuha Tights",
		feet=gear.Herc_TA_feet,
		neck="Erudit. Necklace",
		ear1="Eabani Earring", --4
		ear2="Suppanomimi", --5
		ring1="Petrov Ring",
		ring2="Epona's Ring",
		back="Bleating Mantle",
		waist="Windbuffet Belt +1",
		} -- 14% Gear

	sets.engaged.HighHaste.LowAcc = set_combine(sets.engaged.HighHaste, {
		hands=gear.Herc_TA_hands,
		neck="Combatant's Torque",
		waist="Kentarch Belt +1",
		ring1="Chirich Ring",
		})

	sets.engaged.HighHaste.MidAcc = set_combine(sets.engaged.HighHaste.LowAcc, {
		ammo="Falcon Eye",
		hands=gear.Herc_Acc_hands,
		ear1="Cessance Earring",
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		})

	sets.engaged.HighHaste.HighAcc = set_combine(sets.engaged.HighHaste.MidAcc, {
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		waist="Olseni Belt",
		})

	sets.engaged.HighHaste.STP = set_combine(sets.engaged.HighHaste, {
		ear1="Dedition Earring",
		ear2="Telos Earring",
		ring1="Petrov Ring",
		waist="Kentarch Belt +1",
		})

	-- 47% Magic Haste (36% DW to cap)
	sets.engaged.MaxHaste = {
		ammo="Ginsen",
		head="Dampening Tam",
		body=gear.Herc_TA_body,
		hands=gear.Adhemar_Att_hands,
		legs="Samnuha Tights",
		feet=gear.Herc_TA_feet,
		neck="Erudit. Necklace",
		ear1="Cessance Earring",
		ear2="Brutal Earring",
		ring1="Petrov Ring",
		ring2="Epona's Ring",
		back="Bleating Mantle",
		waist="Windbuffet Belt +1",
		} -- 0%

	sets.engaged.MaxHaste.LowAcc = set_combine(sets.engaged.MaxHaste, {
		hands=gear.Herc_TA_hands,
		neck="Combatant's Torque",
		waist="Kentarch Belt +1",
		ring1="Chirich Ring",
		})

	sets.engaged.MaxHaste.MidAcc = set_combine(sets.engaged.MaxHaste.LowAcc, {
		ammo="Falcon Eye",
		hands=gear.Herc_Acc_hands,
		ear1="Cessance Earring",
		ring2="Ramuh Ring +1",
		back="Letalis Mantle",
		})

	sets.engaged.MaxHaste.HighAcc = set_combine(sets.engaged.MaxHaste.MidAcc, {
		legs=gear.Herc_WS_legs,
		feet=gear.Herc_Acc_feet,
		ear2="Telos Earring",
		ring1="Ramuh Ring +1",
		waist="Olseni Belt",
		})

	sets.engaged.MaxHaste.STP = set_combine(sets.engaged.MaxHaste, {
		neck="Ainia Collar",
		ear1="Dedition Earring",
		ear2="Telos Earring",
		ring1="Petrov Ring",
		waist="Kentarch Belt +1",
		})

	--------------------------------------
	-- Custom buff sets
	--------------------------------------

--	sets.buff.Migawari = {body="Iga Ningi +2"}
	sets.buff.Doom = {ring1="Saida Ring", ring2="Saida Ring", waist="Gishdubar Sash"}
--	sets.buff.Yonin = {}
--	sets.buff.Innin = {}

	sets.CP = {back="Mecisto. Mantle"}
	sets.Reive = {neck="Ygnas's Resolve +1"}

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
	if state.Buff.Doom then
		equip(sets.buff.Doom)
	end
end


-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	if not spell.interrupted and spell.english == "Migawari: Ichi" then
		state.Buff.Migawari = true
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
	-- If we gain or lose any haste buffs, adjust which gear set we target.
	if S{'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
		determine_haste_group()
		if not midaction() then
			handle_equipping_gear(player.status)
		end
	end

	if buffactive['Reive Mark'] then
		equip(sets.Reive)
		disable('neck')
	else
		enable('neck')
	end

	if buff == "doom" then
		if gain then		   
			equip(sets.buff.Doom)
			send_command('@input /p Doomed.')
			disable('ring1','ring2','waist')
		else
			enable('ring1','ring2','waist')
			handle_equipping_gear(player.status)
		end
	end

end

--function job_status_change(new_status, old_status)
--	if new_status == 'Idle' then
--		select_movement_feet()
--	end
--end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Get custom spell maps
function job_get_spell_map(spell, default_spell_map)
	if spell.skill == "Ninjutsu" then
		if not default_spell_map then
			if spell.target.type == 'SELF' then
				return 'NinjutsuBuff'
			else
				return 'NinjutsuDebuff'
			end
		end
	end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Buff.Migawari then
        idleSet = set_combine(idleSet, sets.buff.Migawari)
    end
	if state.CP.current == 'on' then
		equip(sets.CP)
		disable('back')
	else
		enable('back')
	end
--    idleSet = set_combine(idleSet, select_movement_feet())
    return idleSet
end


-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
	if state.Buff.Migawari then
		meleeSet = set_combine(meleeSet, sets.buff.Migawari)
	end
	return meleeSet
end

-- Called by the default 'update' self-command.
function job_update(cmdParams, eventArgs)
--	select_movement_feet()
	determine_haste_group()
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)

	local msg = '[ Melee'
	
	if state.CombatForm.has_value then
		msg = msg .. ' (' .. state.CombatForm.value .. ')'
	end
	
	msg = msg .. ': '
	
	msg = msg .. state.OffenseMode.value
	if state.HybridMode.value ~= 'Normal' then
		msg = msg .. '/' .. state.HybridMode.value
	end
	msg = msg .. ' ][ WS: ' .. state.WeaponskillMode.value
	
	if state.DefenseMode.value ~= 'None' then
		msg = msg .. ' ][ Defense: ' .. state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value
	end
	
	if state.Kiting.value then
		msg = msg .. ' ][ Kiting Mode: ON'
	end
	
	msg = msg .. ' ]'
	
	add_to_chat(060, msg)

	eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()
	-- We have three groups of DW in gear: Hachiya body/legs, Iga head + Patentia Sash, and DW earrings
	
	-- Standard gear set reaches near capped delay with just Haste (77%-78%, depending on HQs)

	-- For high haste, we want to be able to drop one of the 10% groups.
	-- Basic gear hits capped delay (roughly) with:
	-- 1 March + Haste
	-- 2 March
	-- Haste + Haste Samba
	-- 1 March + Haste Samba
	-- Embrava
	
	-- High haste buffs:
	-- 2x Marches + Haste Samba == 19% DW in gear
	-- 1x March + Haste + Haste Samba == 22% DW in gear
	-- Embrava + Haste or 1x March == 7% DW in gear
	
	-- For max haste (capped magic haste + 25% gear haste), we can drop all DW gear.
	-- Max haste buffs:
	-- Embrava + Haste+March or 2x March
	-- 2x Marches + Haste
	
	-- So we want four tiers:
	-- Normal DW
	-- 20% DW -- High Haste
	-- 7% DW (earrings) - Embrava Haste (specialized situation with embrava and haste, but no marches)
	-- 0 DW - Max Haste
	
	classes.CustomMeleeGroups:clear()
	
	if buffactive.embrava and (buffactive.march == 2 or (buffactive.march and buffactive.haste)) then
		classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive.march == 2 and buffactive.haste then
		classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive.embrava and (buffactive.haste or buffactive.march) then
		classes.CustomMeleeGroups:append('EmbravaHaste')
	elseif buffactive.march == 1 and buffactive.haste and buffactive['haste samba'] then
		classes.CustomMeleeGroups:append('HighHaste')
	elseif buffactive.march == 2 then
		classes.CustomMeleeGroups:append('HighHaste')
	end
end


--function select_movement_feet()
--    if world.time >= (17*60) or world.time <= (7*60) then
--        return sets.NightMovement
--    else
--        return sets.DayMovement
 --   end
--end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(2, 11)
	elseif player.sub_job == 'THF' then
		set_macro_page(3, 11)
	else
		set_macro_page(1, 11)
	end
end

function set_lockstyle()
	send_command('wait 2; input /lockstyleset 4')
end