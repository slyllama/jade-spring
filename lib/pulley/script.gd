extends Node

const intro_dialogue_data = {
	"id": "intro",
	"title": "Ratchet",
	"_entry": {
		"string": "(Curse t-t-this infuriating, abhorrent... why won’t it just...) Oh, f-f-friend, good morning! The overnight magnetic realignment h-h-helped, did it?",
		"options": {
			"new_bot": "All three rods seem to be floating just right, Ratchet: I'm feeling like a new bot."
		}
	},
	"new_bot": {
		"string": "M-m-magnificent! So uh, well... want to t-take them for a spin... give them a stretch?",
		"options": {
			"icky": "A stretch, huh - sounds like someone has an icky job lined up for an idle set of jade rods."
		}
	},
	"icky": {
		"string": "I just... These rotten weeds and b-b-bugs; I can't. The static! Swooping and d-d-diving. Worse than Unchained grubs.",
		"options": {
			"alchemy": "It's okay, Ratchet. I'll handle it, starting with the weeds."
		}
	},
	"alchemy": {
		"string": "Thank you, t-t-thank you. Alchemy - t-t-this Dragonvoid has been interfering with t-t-the renovation cataloging system. I'll have to keep w-w-working on it.",
		"options": {
			"handle": "(Leave ratchet to their business.)"
		}
	},
	"handle": {
		"reference": "_exit"
	}
}

const pick_weeds_alt_dialogue = {
	"id": "pick_weeds_alt",
	"title": "Ratchet",
	"_entry": {
		"string": "(Ratchet is mumbling to themselves as they consult data on their heads-up display.)",
		"options": {
			"interference": "What's with the interference?",
			"ship": "How are your ship repairs coming along, Ratchet?",
			"done": "I'll leave you to it."
		}
	},
	"interference": {
		"string": "Shadow of the Dragonvoid... despair... h-h-haze... it inhibits m-m-machinery and renders devices inoperable. We must clear it out if we are to re-engage the renovation c-c-cataloging system.",
		"options": {
			"done": "You've got this, Ratchet.",
			"_entry": "(Ask Ratchet more.)"
		}
	},
	"ship": {
		"string": "Ship-p-p is... sixty-five percent optimal! Dents g-g-gone; engine calibration underway. Thanks, friend; that craft will n-never have t-t-to experience Aetherblade misconduct again.",
		"options": {
			"done": "I'm so happy to hear that, Ratchet. You deserve that; I wouldn't be here recovering if it weren't for you, that's for sure.",
			"_entry": "(Ask Ratchet more.)"
		}
	},
	"done": {
		"reference": "_exit"
	}
}

const clear_bugs_alt_dialogue = {
	"id": "clear_bugs_alt",
	"title": "Ratchet",
	"_entry": {
		"string": "(Ratchet is rapidly mumbling esoteric-sounding calculations.)",
		"options": {
			"stinks": "This stinks, Ratchet!"
		}
	},
	"stinks": {
		"string": "Keep at it-t-t, friend; just g-g-give me a minute. Ratchet has some ideas about clearing out this interference for good.",
		"options": {
			"done": "I'll leave you to it."
		}
	},
	"done": {
		"reference": "_exit"
	}
}

const dv_intro_dialogue = {
	"id": "dv_intro",
	"title": "Ratchet",
	"_entry": {
		"string": "(Ratchet is looking more smug than a Snaff Prize winner.)",
		"options": {
			"communicator": "I... was right over there... did you really need to use the communicator, Ratchet?"
		}
	},
	"communicator": {
		"string": "Standard g-g-golem operating procedure. Now! T-t-take the Raw Dispersion Flux; we're going to attune it in this genius m-machine I've developed.",
		"options": {
			"procedure": "(...)"
		}
	},
	"procedure": {
		"string": "Each Dragonvoid blight seems to resonate with the m-magic of a certain Elder Dragon. Use the device to play a melody and t-t-tune the flux to the correct Dragon, and then you can dispel it as you would any old bug!",
		"options": {
			"got_this": "(Through the communicator) I'll check it out; I've got this. Over!"
		}
	},
	"got_this": {
		"reference": "_exit"
	}
}

const no_dv_charge = {
	"id": "no_dv_charge",
	"title": "Ratchet",
	"_entry": {
		"string": "Your c-c-circuit functions are stable... no energy spikes... no anomalies... you mustn't have used t-t-the Attenuator yet, huh. N-no, it's perfectly safe.",
		"options": {
			"done": "Okay..."
		}
	},
	"done": {
		"reference": "_exit"
	}
}

const gift_letter = {
	"id": "gift_letter",
	"title": "Ratchet",
	"_entry": {
		"string": "Ahhh; y-you're still in one piece. (RELIEF REGISTERED.) You've really helped-d-d make this place into a g-gem of Cantha.",
		"options" : {
			"commander": "I can't wait until the Commander can see this. Thanks, Ratchet."
		}
	},
	"commander": {
		"string": "Thank (YOU). Oh, and: my m-master has something for you, should you choose to s-stay around and clear everything out-t-t.",
		"options": {
			"exit": "(Take Ratchet's letter.)"
		}
	},
	"exit": {
		"reference": "_exit"
	}
}

const dv_charge = {
	"id": "dv_charge",
	"title": "Ratchet",
	"_entry": {
		"string": "Beep... Static... Buzz...",
		"options": {
			"weird": "I feel... a little faint, Ratchet. Is this attuning thing... safe?"
		}
	},
	"weird": {
		"string": "T-t-the zapping, the energy... aha. Ahaha! Yes - it's w-w-working!",
		"options": {
			"safe": "(...)"
		}
	},
	"safe": {
		"string": "O-oh... I mean... yes, yes, it's entirely s-s-safe. It just incurs, well... a small m-m-memory leak. Noted for next t-time.",
		"options": {
			"done": "I hope so; my mind... it's scrambled."
		}
	},
	"done": {
		"reference": "_exit"
	}
}

const raiqqo_dialogue = {
	"id": "raiqqo",
	"title": "Ratchet",
	"_entry": {
		"string": "A good day in the Jade Spring - especially now that awful b-b-buzzing has d-dialed back a little.",
		"options": {
			"saved_1": "Raiqqo saved me; he repaired me and made me whole again. And yet... I recall so little of what happened.",
			"return_1": "I'm glad we've been able to restore some order to this place before Raiqqo got back. That was thoughtful of him to leave a letter.",
			"commander_1": "I can't wait till the Commander sees what we've done here. They could use a break.",
			"done": "(Done for now.)"
		}
	},
	"saved_1": {
		"string": "Rai is a cap-pable one; a t-true Static, huh.",
		"options": {
			"saved_2": "(...)"
		}
	},
	"saved_2": {
		"string": "He said the same t-thing as when he patched me up - that we were b-both solely practical endeavors, n-nothing more.",
		"options": {
			"saved_3": "(...)"
		}
	},
	"saved_3": {
		"string": "But we both know that isn't true.",
		"options": {
			"_entry": "(Discuss more with Ratchet.)"
		}
	},
	"return_1": {
		"string": "Well, the letter and the gift-t-t... Don't tell him I d-divulged this—",
		"options": {
			"return_2": "(...)"
		}
	},
	"return_2": {
		"string": "—But... Rai thinks you have 'perhaps a little more than a little merit'; h-his words, not mine.",
		"options": {
			"return_3": "(...)"
		}
	},
	"return_3": {
		"string": "He would like t-to have you around with him, part-time at-t-t least.",
		"options": {
			"_entry": "(Discuss more with Ratchet.)"
		}
	},
	"commander_1": {
		"string": "I've heard t-the rocks are stirring in the isles of T-t-Tyria they wander. When they return, p-perhaps they can speak to us of t-the talking bears.",
		"options": {
			"commander_2": "(...)"
		}
	},
	"commander_2": {
		"string": "Rai wonders if they are m-much different from the snow bears; I've only retained t-the vaguest memories of the Shiverpeaks.",
		"options": {
			"_entry": "(Discuss more with Ratchet.)"
		}
	},
	"done": {
		"reference": "_exit"
	}
}

const gift = {
	"id": "gift",
	"title": "Ratchet",
	"_entry": {
		"string": "((Receive gift.))",
		"options": {
			"exit": "((Receive gift.))"
		}
	},
	"exit": {
		"reference": "_exit"
	}
}
