/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/blank.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	density = FALSE
	visible_message(span_danger("[src] fades away."))
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes
	light_range = 0
	light_power = 0
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	density = initial(density)
	invisibility = 0
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is [anchored ? "":"not "]secured to the floor.")
	if((iscultist(user) || isobserver(user)) && cooldowntime > world.time)
		. += span_cultitalic("The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].")

/obj/structure/destructible/cult/examine_status(mob/user)
	if(iscultist(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		return span_cult("[t_It] [t_is] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		if(obj_integrity < max_integrity)
			M.changeNext_move(CLICK_CD_MELEE)
			obj_integrity = min(max_integrity, obj_integrity + 5)
			Beam(M, icon_state="sendbeam", time=4)
			M.visible_message(span_danger("[M] repairs \the <b>[src]</b>."), \
				span_cult("I repair <b>[src]</b>, leaving [p_they()] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability."))
		else
			to_chat(M, span_cult("I cannot repair [src], as [p_theyre()] undamaged!"))
	else
		..()

/obj/structure/destructible/cult/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		anchored = !anchored
		to_chat(user, span_notice("I [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor."))
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		return ..()

/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = ""
	icon_state = "talismanaltar"
	break_message = span_warning("The altar shatters, leaving only the wailing of the damned!")

/obj/structure/destructible/cult/talisman/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("I need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/choice = alert(user,"You study the schematics etched into the altar...",,"Eldritch Whetstone","Construct Shell","Flask of Unholy Water")
	var/list/pickedtype = list()
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype += /obj/item/sharpener/cult
		if("Construct Shell")
			pickedtype += /obj/structure/constructshell
		if("Flask of Unholy Water")
			pickedtype += /obj/item/reagent_containers/glass/beaker/unholywater
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("I kneel before the altar and your faith is rewarded with the [choice]!"))

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = ""
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = span_warning("The force breaks apart into shards with a howling scream!")

/obj/structure/destructible/cult/forge/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("The heat radiating from [src] pushes you back."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("I need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/choice
	if(user.mind.has_antag_datum(/datum/antagonist/cult/master))
		choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Mirror Shield")
	else
		choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Mirror Shield")
	var/list/pickedtype = list()
	switch(choice)
		if("Shielded Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Mirror Shield")
			pickedtype += /obj/item/shield/mirror
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("I work the forge as dark knowledge guides your hands, creating the [choice]!"))



/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = ""
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	break_sound = 'sound/blank.ogg'
	break_message = span_warning("The blood-red crystal falls to the floor and shatters!")
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/destructible/cult/pylon/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")
					if(ishuman(L))
						L.adjustBruteLoss(-1, 0)
						L.adjustFireLoss(-1, 0)
						L.updatehealth()
					if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-3)
				if(ishuman(L) && L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0
			CHECK_TICK
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/engine/cult,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = ""
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = span_warning("The books and tomes of the archives burn into ash as the desk shatters!")

/obj/structure/destructible/cult/tome/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("These books won't open and it hurts to even try and read the covers."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("I need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Zealot's Blindfold","Shuttle Curse","Veil Walker Set")
	var/list/pickedtype = list()
	switch(choice)
		if("Zealot's Blindfold")
			pickedtype += /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			pickedtype += /obj/item/shuttle_curse
		if("Veil Walker Set")
			pickedtype += /obj/item/cult_shift
			pickedtype += /obj/item/flashlight/flare/culttorch
	if(src && !QDELETED(src) && anchored && pickedtype.len && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("I summon the [choice] from the archives!"))

/obj/effect/gateway
	name = "gateway"
	desc = ""
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
