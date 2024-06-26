/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	id = "mush"
	default_features = MANDATORY_FEATURE_LIST
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	fixed_mut_color = "DBBF92"
	hair_color = "FF4B19" //cap color, spot color uses eye color
	nojumpsuit = TRUE

	say_mod = "poofs" //what does a mushroom sound like
	species_traits = list(MUTCOLORS, NOEYESPRITES, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_NOFLASH)
	inherent_factions = list("mushroom")
	speedmod = 1.5 //faster than golems but not by much

	punchdamagelow = 6
	punchdamagehigh = 14
	punchstunthreshold = 14 //about 44% chance to stun

	no_equip = list(SLOT_WEAR_MASK, SLOT_ARMOR, SLOT_GLOVES, SLOT_SHOES, SLOT_PANTS)

	burnmod = 1.25
	heatmod = 1.5

	use_skintones = FALSE
	var/datum/martial_art/mushpunch/mush

/datum/species/mush/check_roundstart_eligible()
	return FALSE //hard locked out of roundstart on the order of design lead kor, this can be removed in the future when planetstation is here OR SOMETHING but right now we have a problem with races.

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		mush = new(null)
		mush.teach(H)

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	mush.remove(C)
	QDEL_NULL(mush)

/datum/species/mush/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone/weedkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
