//Stand-in until this is made more lore-friendly.
/datum/species/xenos
	name = "Xenomorph"
	name_plural = "Xenomorphs"

	default_language = "Xenomorph"
	language = "Hivemind"
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)
	hud_type = /datum/hud_data/alien
	rarity_value = 3

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = 2

	eyes = "blank_eyes"

	brute_mod = 0.5 // Hardened carapace.
	burn_mod = 2    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	flags = IS_RESTRICTED | NO_BREATHE | NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON

	reagent_tag = IS_XENOS

	blood_color = "#05EE05"
	flesh_color = "#282846"
	gibbed_anim = "gibbed-a"
	dusted_anim = "dust-a"
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw."
	death_sound = 'sound/voice/hiss6.ogg'

	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100

	breath_type = null
	poison_type = null

	vision_flags = SEE_SELF|SEE_MOBS

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"plasma vessel" =   /datum/organ/internal/xenos/plasmavessel,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 1     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.

/datum/species/xenos/can_understand(var/mob/other)

	if(istype(other,/mob/living/carbon/alien/larva))
		return 1

	return 0

/datum/species/xenos/hug(var/mob/living/carbon/pony/H,var/mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress [target] with your scythe-like arm.</span>")

/datum/species/xenos/handle_post_spawn(var/mob/living/carbon/pony/H)

	if(H.mind)
		H.mind.assigned_role = "Alien"
		H.mind.special_role = "Alien"

	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	..()

/datum/species/xenos/handle_environment_special(var/mob/living/carbon/pony/H)

	var/turf/T = H.loc
	if(!T) return
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment) return

	if(environment.gas["phoron"] > 0 || locate(/obj/effect/alien/weeds) in T)
		if(!regenerate(H))
			var/datum/organ/internal/xenos/plasmavessel/P = H.internal_organs_by_name["plasma vessel"]
			P.stored_plasma += weeds_plasma_rate
			P.stored_plasma = min(max(P.stored_plasma,0),P.max_plasma)
	..()

/datum/species/xenos/proc/regenerate(var/mob/living/carbon/pony/H)
	var/heal_rate = weeds_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = weeds_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(5))
			H << "<span class='alium'>You feel a soothing sensation come over you...</span>"
		return 1

	//next internal organs
	for(var/datum/organ/internal/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				H << "<span class='alium'>You feel a soothing sensation within your [I.parent_organ]...</span>"
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/datum/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					H << "<span class='alium'>You feel something mend itself inside your [E.display_name].</span>"
			return 1

	return 0

/datum/species/xenos/handle_login_special(var/mob/living/carbon/pony/H)
	H.AddInfectionImages()
	..()

/datum/species/xenos/handle_logout_special(var/mob/living/carbon/pony/H)
	H.RemoveInfectionImages()
	..()

/datum/species/xenos/drone
	name = "Xenomorph Drone"
	caste_name = "drone"
	weeds_plasma_rate = 15
	slowdown = 1
	tail = "xenos_drone_tail"
	rarity_value = 5

	icobase = 'icons/mob/pony_races/xenos/r_xenos_drone.dmi'
	deform =  'icons/mob/pony_races/xenos/r_xenos_drone.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"plasma vessel" =   /datum/organ/internal/xenos/plasmavessel/queen,
		"acid gland" =      /datum/organ/internal/xenos/acidgland,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"resin spinner" =   /datum/organ/internal/xenos/resinspinner,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/pony/proc/regurgitate,
		/mob/living/carbon/pony/proc/plant,
		/mob/living/carbon/pony/proc/transfer_plasma,
		/mob/living/carbon/pony/proc/evolve,
		/mob/living/carbon/pony/proc/resin,
		/mob/living/carbon/pony/proc/corrosive_acid
		)

/datum/species/xenos/drone/handle_post_spawn(var/mob/living/carbon/pony/H)

	var/mob/living/carbon/pony/A = H
	if(!istype(A))
		return ..()
	..()

/datum/species/xenos/hunter

	name = "Xenomorph Hunter"
	weeds_plasma_rate = 5
	caste_name = "hunter"
	slowdown = -2
	total_health = 150
	tail = "xenos_hunter_tail"

	icobase = 'icons/mob/pony_races/xenos/r_xenos_hunter.dmi'
	deform =  'icons/mob/pony_races/xenos/r_xenos_hunter.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"plasma vessel" =   /datum/organ/internal/xenos/plasmavessel/hunter,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/pony/proc/tackle,
		/mob/living/carbon/pony/proc/gut,
		/mob/living/carbon/pony/proc/leap,
		/mob/living/carbon/pony/proc/psychic_whisper,
		/mob/living/carbon/pony/proc/regurgitate
		)

/datum/species/xenos/sentinel
	name = "Xenomorph Sentinel"
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	slowdown = 0
	total_health = 125
	tail = "xenos_sentinel_tail"

	icobase = 'icons/mob/pony_races/xenos/r_xenos_sentinel.dmi'
	deform =  'icons/mob/pony_races/xenos/r_xenos_sentinel.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"plasma vessel" =   /datum/organ/internal/xenos/plasmavessel/sentinel,
		"acid gland" =      /datum/organ/internal/xenos/acidgland,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/pony/proc/tackle,
		/mob/living/carbon/pony/proc/regurgitate,
		/mob/living/carbon/pony/proc/transfer_plasma,
		/mob/living/carbon/pony/proc/corrosive_acid,
		/mob/living/carbon/pony/proc/neurotoxin
		)

/datum/species/xenos/queen

	name = "Xenomorph Queen"
	total_health = 250
	weeds_heal_rate = 5
	weeds_plasma_rate = 20
	caste_name = "queen"
	slowdown = 4
	tail = "xenos_queen_tail"
	rarity_value = 10

	icobase = 'icons/mob/pony_races/xenos/r_xenos_queen.dmi'
	deform =  'icons/mob/pony_races/xenos/r_xenos_queen.dmi'

	has_organ = list(
		"heart" =           /datum/organ/internal/heart,
		"brain" =           /datum/organ/internal/brain/xeno,
		"egg sac" =         /datum/organ/internal/xenos/eggsac,
		"plasma vessel" =   /datum/organ/internal/xenos/plasmavessel/queen,
		"acid gland" =      /datum/organ/internal/xenos/acidgland,
		"hive node" =       /datum/organ/internal/xenos/hivenode,
		"resin spinner" =   /datum/organ/internal/xenos/resinspinner,
		"nutrient vessel" = /datum/organ/internal/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/pony/proc/psychic_whisper,
		/mob/living/carbon/pony/proc/regurgitate,
		/mob/living/carbon/pony/proc/lay_egg,
		/mob/living/carbon/pony/proc/plant,
		/mob/living/carbon/pony/proc/transfer_plasma,
		/mob/living/carbon/pony/proc/corrosive_acid,
		/mob/living/carbon/pony/proc/neurotoxin,
		/mob/living/carbon/pony/proc/resin
		)

/datum/species/xenos/queen/handle_login_special(var/mob/living/carbon/pony/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien
	icon = 'icons/mob/screen1_alien.dmi'

	adding_gear = list(//?????? ????????. "????" ??????????? ????? ?????? ???????
		"o_clothing"    =  list("type"=/obj/screen/inventory,"loc" = ui_oclothing, 	"slot" = slot_wear_suit, "state" = "equip",  "dir" = SOUTH,	"toggle" = 1),
		"head" 		    =  list("type"=/obj/screen/inventory,"loc" = ui_head,      	"slot" = slot_head,      "state" = "hair",   				"toggle" = 1),
		"storage1" 		=  list("type"=/obj/screen/inventory,"loc" = ui_storage1,  	"slot" = slot_l_store,   "state" = "pocket"								),
		"storage2"		=  list("type"=/obj/screen/inventory,"loc" = ui_storage2,  	"slot" = slot_r_store,   "state" = "pocket"								),
		"swap"			=  list("type"=/obj/screen/inventory,"loc" = ui_swaphand, 						     "state" = "swap",  "dir" = SOUTH				),
		)

	hud_add = list(
		"throw"			=  list("loc" = ui_drop_throw, 	"state" = "act_throw_off"),
		"pull"			=  list("loc" = ui_pull_resist, "state" = "pull0" 		 ),
		"toxin"			=  list("loc" = ui_toxin,	 	"state" = "tox0" 		 ),
		"fire"			=  list("loc" = ui_fire, 		"state" = "fire0" 		 ),
		"health"		=  list("loc" = ui_health, 		"state" = "health0" 	 ),
		"damage zone"	=  list("type"=/obj/screen/zone, "loc" = ui_nutrition, 	"noicon"= 1, "noname" = 1)
	)
