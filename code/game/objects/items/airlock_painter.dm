/obj/item/airlock_painter
	name = "airlock painter"
	desc = ""
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = WEIGHT_CLASS_SMALL

	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/blank.ogg'

	var/obj/item/toner/ink = null

/obj/item/airlock_painter/Initialize()
	. = ..()
	ink = new /obj/item/toner(src)

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
		return 1
	else
		return 0

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		to_chat(user, span_warning("There is no toner cartridge installed in [src]!"))
		return 0
	else if(ink.charges < 1)
		to_chat(user, span_warning("[src] is out of ink!"))
		return 0
	else
		return 1

/obj/item/airlock_painter/suicide_act(mob/user)
	var/obj/item/organ/lungs/L = user.getorganslot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message(span_suicide("[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!isopenturf(T))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message(span_suicide("[user] vomits out [user.p_their()] [L]!"))
		playsound(user.loc, 'sound/blank.ogg', 50, TRUE)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message(span_suicide("[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide."))
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message(span_suicide("[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner."))
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += span_notice("It doesn't have a toner cartridge installed.")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	. += span_notice("Its ink levels look [ink_level].")


/obj/item/airlock_painter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, span_warning("[src] already contains \a [ink]!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("I install [W] into [src]."))
		ink = W
		playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
	else
		return ..()

/obj/item/airlock_painter/attack_self(mob/user)
	if(ink)
		playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, span_notice("I remove [ink] from [src]."))
		ink = null
