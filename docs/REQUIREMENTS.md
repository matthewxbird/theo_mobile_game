# Teddy's Sweet Run: Requirements

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
- Teddy walks over his own honey without slipping.

## Getting caught

- **Never game over.** (kid's pick) When a monster catches Teddy, he drops a few sweets (lose up to 3 points, never below 0).
- Teddy then blinks and is safe for 2 seconds so he can get away.
- The monster that caught him bounces back a little.

## Making it easy for a 4-year-old

- Monsters are slower than Teddy, always.
- Few monsters at once: start with 1, slowly grow to a maximum of 3.
- A new monster appears at the edge of the screen a few seconds after one disappears, never right next to Teddy.
- Big, bright, friendly art. Large touch targets (the honey button is at least 80 px).
- No timers, no fail state, no menus to get through. Open the app and play.
- Sounds and pictures instead of words.

## Out of scope for the first version

- Levels, menus, settings, saving high scores.
- Multiple playgrounds or characters.

## Ideas for later (the "programming" part)

- **Build a path:** instead of tapping, the player lays out arrow cards (up, up, right) and presses Go to watch Teddy follow them. This is a first taste of programming.
- Let our player design his own playground by placing sweets, honey and monsters.
- Our player's own drawings as the art for Teddy and the monsters.

## Open questions

- Is 3 honey pots to start the right number?
- What does a "sweet" look like: lollipops, wrapped sweets, cupcakes, a mix?
- Should the game have music, or only sound effects?
