# Theo's Sweet Run: Requirements

A simple game for a 4-year-old, made to spark an interest in programming.
Decisions marked **(kid's pick)** were picked by our player. Others are sensible defaults we can change.

## Core idea

Teddy runs around a playground collecting sweets. Grumpy monsters wander about trying to catch him.
Teddy can drop honey to make monsters slip over and disappear.

## Characters

| Who | What they do |
| --- | --- |
| **Teddy** (kid's pick) | The hero. A teddy bear the player moves around. |
| **Grumpy monsters** (kid's pick) | Silly, round, not-scary blob monsters. They walk slowly towards Teddy. |

## Controls

- **Tap to go there** (kid's pick): tap anywhere and Teddy walks to that spot.
- **Honey button**: one big button in the corner drops a honey puddle where Teddy is standing.
- No other controls. No reading needed to play.

## Sweets and points

- Sweets appear around the playground. Teddy picks one up by walking over it.
- Each sweet is worth 1 point. The score is shown as a big number with a sweet icon.
- When a sweet is collected, a new one appears somewhere else, so there are always sweets on screen.
- Happy sound and a little sparkle on every pickup.

## Honey traps (the escape mechanic)

- **No weapons.** (parent)
- Teddy drops a honey puddle with the honey button. **Each honey trap is single use.** (kid's pick)
- When a monster walks into honey it **slips over and disappears** (kid's pick): a funny wobble, a "whoops" sound, then it pops in a puff.
- The puddle is used up after one monster.
- Teddy starts with 3 honey pots. Collect honey jars around the level to get more. The honey button shows how many pots are left and goes grey at zero.
- **4 honey pots turn into 1 bee (beehive).** When the 4th pot is collected, a magic animation plays: 4 pots fly out of the honey button with counting badges (1, 2, 3, 4), swirl together, go poof in a sparkle burst, and a bee pops out, wiggles, and flies to the bee button. Twinkly magic sound, then a buzz.
- Teddy walks over his own honey without slipping.

## Getting caught

- **Never game over.** (kid's pick) When a monster catches Teddy, it **steals a lollipop and eats it** (never below 0). The lollipop flies into the monster's mouth with a "nom nom nom" and is gone for good.
- Teddy then blinks and is safe for 2 seconds so he can get away.
- The monster that caught him bounces back a little.

## Hats (kid's pick)

- **A new hat appears every 10 seconds whenever there isn't one on the floor** (a special magic top hat, twinkling).
- Walk over it and Teddy puts it on (it drops onto his head with a bounce and a "ta-da!"). A pulsing yellow ring around him means "tap me".
- **Tap Teddy** and he throws the spinning hat at the nearest bad guy. It lands over the bad guy's eyes; it panics ("yikes!") and runs off the screen. It's gone for good.
- **Teddy wears only one hat at a time**: while he has one on, he walks straight past a hat on the floor. There's never more than one hat on the floor. If there are no bad guys, tapping Teddy keeps the hat on.

## Bad bats (kid's pick)

- About 2 in 5 new bad guys are **bad bats** instead of grumpy monsters: flapping wings, pointy ears, little fangs. They bob as they fly and swoop from side to side.
- Bats follow all the same rules: they steal and eat lollipops, get fat and hungry, slip in honey, get stung by bees, and run away blinded by the hat.

## Animation

- **Teddy:** waddles and bounces when walking, breathes when standing, blinks, looks where he's going, rosy cheeks, hops for joy with a big grin on every pickup, leans back and flings the hat, makes an "oh!" face when caught. His hat sways as he walks.
- **Bad guys:** pop out of the ground in a dust puff (bats swoop in), eyes follow Teddy and blink, waddle when fat, tummy-rumble shake when starving, open mouth and teeth when close to Teddy, smug grin after a catch, dizzy stars and X eyes when slipping, red bumps when stung.

## App icon

- Happy Teddy in his magic hat holding a lollipop, on the sky-and-grass background. Drawn from the game's own art.

## Hungry monsters (why you should deal with them)

- **Each lollipop a monster eats makes it fatter and slower** (up to 3 lollipops' worth). It gets visibly wider and waddles.
- The fat wears off over time (about 7 seconds per lollipop), so it speeds back up.
- **The longer a monster goes without eating, the hungrier and faster it gets** (up to 40% faster after 20 seconds). Hungry monsters drool and jiggle faster.
- So leaving monsters alone gets riskier: use honey or the beehive to get rid of them. Even the hungriest monster is still slower than Teddy.

## Levels

- **Level 1 ends at 6 lollipops; each level needs 2 more** (8, 10, 12, 14), **up to 16** from level 6 on, so later levels never drag on for a 5-year-old.
- **A new place every level** (kid's pick: every level looks different from the last): meadow 🌼, beach 🏖️ (rolling waves, shells and starfish), snow ❄️ (drifts and falling snowflakes), night 🌙 (moon and twinkling stars), then round again. The "Get ready" countdown shows the place. At night most bad guys are bats, in bright colours so they're easy to see.
- The lollipop count shows progress for this level (e.g. `3/6`); a star badge shows the level.
- Each level has one more monster (up to 3), and monsters get a bit faster, but always stay slower than Teddy.
- Finishing a level makes all monsters flash and fade away.

## Beehive (bonus)

- **You get 1 beehive each time you finish a level.** Beehives build up across levels.
- Tap the beehive button: bees fly from Teddy to **every** monster, sting them, and the monsters flash and fade out.
- A beehive isn't used up if there are no monsters to sting.

## Screens

- **Start screen:** pick your teddy colour (brown, pink, blue, purple, gold, red) and press the big Play button.
- **Get ready:** "Level N", then a big "3, 2, 1, Go!" countdown before every level, so the game never starts by surprise.
- **Level complete party:** "Yay!", confetti, three stars popping in with blings, your teddy dancing, a "+1 🐝" prize, and a big pulsing **🚀 Level N** button. The next level only starts when the button is pressed. A small 🏠 button goes back to the start screen.

## Leaderboard

- Each player picks a **teddy colour** instead of typing a name (a 4-year-old can't type yet).
- The start screen shows every teddy with ⭐ = the most levels that teddy has finished. The leader wears a 👑.
- Saved on the phone, so it's still there next time.

## Making it easy for a 4-year-old

- Monsters are slower than Teddy, always.
- Few monsters at once: 1 on level 1, up to a maximum of 3.
- A new monster appears at the edge of the screen a few seconds after one disappears, never right next to Teddy.
- Big, bright, friendly art. Large touch targets (bonus buttons are over 100 px).
- No timers and no fail state.
- Sounds and pictures instead of words.

## Out of scope for now

- Settings, typed names.
- Multiple playgrounds or characters.

## Ideas for later (the "programming" part)

- **Build a path:** instead of tapping, the player lays out arrow cards (up, up, right) and presses Go to watch Teddy follow them. This is a first taste of programming.
- Let our player design his own playground by placing sweets, honey and monsters.
- Our player's own drawings as the art for Teddy and the monsters.

## Open questions

- Is 3 honey pots to start the right number?
- What does a "sweet" look like: lollipops, wrapped sweets, cupcakes, a mix?
- Should the game have music too? Sound effects are in: a bling for sweets, a tune for honey jars, a bloop for dropping honey, a whoops-and-pop for slipping monsters, and a boing when caught.
