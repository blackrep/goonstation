#define STATUS_LINKED 0
#define STATUS_UNLINKED 1
#define STATUS_ACTIVE 2
#define STATUS_ERROR 3

/obj/item/remote_explosive
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes." // cogwerks - changed the name
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "remote_explosive-unlinked"
	// Remote that controls the explosive, can only be linked to a single one
	var/obj/item/pinpointer/detonator_remote/remote = null
	var/active = FALSE
	var/timer = 5 SECONDS
	var/strength = 32

	disposing()
		if (!isnull(src.remote))
			src.remote.unregister_explosive()
		..()

	proc/can_link()
		return !src.active && isnull(src.remote)

	proc/can_unlink()
		return !src.active && !isnull(src.remote)

	ex_act(severity)
		src.active = TRUE
		src.blowthefuckup(strength, TRUE)
		. = ..()

	attackby(obj/item/W, mob/user, params)
		if (!istype(W, /obj/item/pinpointer/detonator_remote))
			return

		var/obj/item/pinpointer/detonator_remote/remote = W
		remote.update_explosives(user, src)

	update_icon()
		if (src.active)
			src.icon_state = "remote_explosive-active"
		else if (isnull(src.remote))
			src.icon_state = "remote_explosive-unlinked"
		else
			src.icon_state = "remote_explosive-linked"
		..()

	proc/attempt_link(mob/user, obj/item/pinpointer/detonator_remote/remote)
		if (!src.can_link())
			// TODO: Add visible msg & sound saying you attempt to link the explosive but fail
			src.play_status_msg(user, remote, STATUS_ERROR)
			return FALSE
		// TODO: Add visible msg & sound saying you attempt to link the explosive and it succeeds
		src.remote = remote
		src.play_status_msg(user, remote, STATUS_LINKED)
		src.UpdateIcon()
		return TRUE

	proc/attempt_unlink(mob/user, obj/item/pinpointer/detonator_remote/remote, var/disposing = FALSE)
		if (disposing || (src.can_unlink() && src.remote == remote))
			src.remote = null
			src.play_status_msg(user, remote, STATUS_UNLINKED)
			src.UpdateIcon()
			return TRUE
		// TODO: Add visible msg & sound saying you attempt to unlink the explosive but fail
		src.play_status_msg(user, remote, STATUS_ERROR)
		return FALSE

	proc/play_status_msg(mob/user, obj/item/pinpointer/detonator_remote/remote, var/status)
		var/sound = null
		var/msg = null
		var/msg_group = null
		switch(status)
			if (STATUS_LINKED)
				sound = 'sound/machines/tone_beep.ogg'
				msg = "<span class='alert'>The [src]'s receiver makes a happy beep. It looks like it's been linked to a detonator.</span>"
				msg_group = "bomblink"
			if (STATUS_UNLINKED)
				sound = 'sound/machines/bweep.ogg'
				msg = "<span class='alert'>The [src]'s receiver makes a sad bweep. It looks like it was unlinked from it's detonator.</span>"
				msg_group = "bombunlink"
			if (STATUS_ACTIVE)
				sound = 'sound/machines/buzz-two.ogg'
				msg = "<span class='alert'>The [src]'s receiver begins ticking. It looks like it's about to explode!</span>"
				msg_group = "bombactive"
			if (STATUS_ERROR)
				sound = 'sound/machines/buzz-two.ogg'
				msg = "<span class='alert'>The [src]'s receiver makes a buzz. It seems something went wrong.</span>"
				msg_group = "bomberror"
			else
				return

		var/turf/T = get_turf(src)
		T.tri_message(
			user,
			msg,
			ignore_second_target = TRUE,
			group = msg_group,
		)
		if (!ON_COOLDOWN(src, "playsound", 0.2 SECONDS))
			playsound(src.loc, sound, 20, 1)

#undef STATUS_LINKED
#undef STATUS_UNLINKED
#undef STATUS_ACTIVE
#undef STATUS_ERROR
