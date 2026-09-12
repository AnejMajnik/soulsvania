# 25.6.2026:
- Created the base godot project
- Made the main Game scene
- Made player scene, added AnimatedSprite2D child node and CollisionShape2D child node
- Exported spritesheet from Aseprite, imported it into AnimatedSprite2D, made 3 basic animations: idle, run and attack_combo
- Added Player scene to the main Game scene and added a camera that follows it
- Added input events: jump, move_left, move_right and attack_combo, and bound inputs to it (A, D, space and Left mouse click, as well as controller bindings
- Added player script, made a basic read_inputs function that handles movement and animations based on events
- Using is_attacking bool as flag during attack animation, otherwise it would cancel out instantly by idle animation
- Made basic ground tilesheet in Aseprite and imported it into Godot
- Added a TileMapLayer node to the main Game scene, added the ground tiles to it, added collision layer 1 to the top one that the player character interacts with
- Wired up jump animation and changed the animation play logic to correctly switch between animations
- Added interrupts to attack and jump animations to prevent it getting stuck in either of them as you interrupt it with another
- Added flag is_jumping
- Increased arena size and added camera bounds to it, so that it stops at the edges
- Added DECCELERATION_SPEED const, that I use for stopping on ground, removed ability to stop mid air if you release key for better feel
- Added double jump, adjusted JUMP_VELOCITY
- Made a prototype cube with telegraphing by flashing red faster and faster
- Imported spritesheet into Godot
- Made another CharacterBody2D for the enemy cube, added idle, attack and telegraph animations, added CollisionShape2D
- Made a simple enemy script with chase mechanic, so that it always follows the player
- Added enum of States that the prototype state machine uses { CHASE, TELEGRAPH, ATTACK, RECOVER }
- Made a basic match statement (GDScript equivelant of switch) for different states, and made a simple state machine
- If a player is more than 100 distance away, initialte telegraphing. Then attack by jumping to the player position at the start of attack. Once it lands, a timer starts for 1s where it recovers, then starts chasing again
- The cube was jumping a little short. Turns out, at the very start of the jump, is_on_floor() was true, which meant it decreased the velocity slightly. Added an "current_state != State.ATTACK" check, and it fixed the issue
- Added Area2D to the player with collision shape. At first it did not flip with my character, turns out Area2D position was 0, 0 while collision body had coords, and i was tryin to flip area2d.. I swapped them and it worked
- Added on body entered and on body exited signals for it, so that during my attack animation, on frames 4 and 8 where it actually hits, i can check if the enemy is inside, and if so, it takes damage.
- Added Area2D to the enemy box, added a timer for 0.5S so that i take damage first time i enter its area2D, then every 0.5s
- Made it so that if I kill the enemy, it despawns. If the enemy kills me, it restarts the game.


# 27.6.2026:
## Bug fix on end condition
- Once I killed the enemy, if I attack again, I would get a null error and the game would crash
- Afer some debugging, I fixed it by adding a null check inside attack frame logic. This happened because If a player despawns inside the Area2D of my attack, it technically has not exited, so that signal does not fire. However, it is null, so the game breaks

## Code in question (likely to get refactored later):
func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite and animated_sprite.animation == "attack_combo":
		if animated_sprite.frame in [4, 8]:
			if current_enemy != null and current_enemy == enemy_cube:
				enemy_cube.get_hit(attack_combo_dmg)

## New cube attack - dash
- Added a new enum to the cube script, Attacks { JUMP, DASH }
- Implemented the dash_attack function, that gets the direction of the player, then does a dash towards it
- I use a random function (randf) that generates a float between 0 and 1. Currently, there is 50/50 chance on which attack it will choose
- I needed a way to end the attack, so I added RayCast2D on left and right side, that detects collision on either side - meaning that it will dash until it hits a wall
- I then use ray_cast_left.is_colliding() and same for the right side, then end the attack and enter recovery mode
- This new attack fixed the issue of being able to just move left and right under the cube to dodge jumps
- At this point, the cube prototype boss fight is getting quite challenging. Part of it is because the player cant tell the difference between the attacks in telegraphing, so I will need to add a way to differentiate between the attacks it will do

## Bug fix - On scene reload, move_and_slide() got an error: Parameter "body->get_space()" is null
- Because the player character was not in the scene for a split second while the scene reloaded, move_and_slide printed errors because it needs a body to work on
- Fixed this by first setting set_physics_process(false). This stopped _physics_process calls for a bit
- Then I called the reload_current_scene by using call_deferred("reload_current_scene") instead. This runs after the frame finishes
- Then i exit out of the function before move_and_slide() runs again
- Because reload_current_scene reloads everything fresh, it works again after reload


# 28.6.2026:
## Making the fight more fair
- To make the fight more fair, i drew up another simple telegraphing animation, switching colors from red flashing to yellow flashing
- Refactored the code, so that it chooses the attack before it telegraphs, otherwise it has no way of choosing the right telegraph for the right attack - before it chose it after telegraph
- This made the fight too easy, as player can easily predict which attack it was. I played around with the speed of telegraphing to try and fix this, for now I landed on increasing it from 8 fps to 12 fps, meaning that telegraphing which is 10 frames long takes a little less than a second, giving player less time to react
- This keeps the fight about equally challenging as before, but the challenge comes from reading the telegraphing and reacting to it appropriately (either jumping or moving on the ground) based on the telegraphing, instead of just waiting for the attack to happen and hoping its fast enough


# 4.7.2026:
## New animations
- Over the past few days, I made actual animations for the prototype enemy AI - a boss slime
- Made Idle animation, Move animation, Jump telegraph (squish down), Jump attack animation, landing animation, dash telegraph (tilts in the opposite direction before dashing), dash, and stagger/recover animation
- Added it into godot, adjusted the hitbox to reflect that, as well as raycast
- Added new animations to play, since before there were only idle, and 2 telegraph animations

### Balancing
- With new animations, there comes new amount of frames. Which means the telegraphs need adjusted FPS values, as currently end of telegraph and start of attack relies on end of telegraph animation.
- Also added a new landing animation, for which I will need to add another raycast that checks below the enemy, if there is ground
- The new dash telegraph made it really easy to see the dash, so I sped it up a bit, as well as increased dash speed - this makes it a little tougher to react, but still fair
- If you stood a little higher and the slime was in the corner, if it dashed it basically did nothing, so I added a check when choosing attacks, if ray cast left or right is colliding, it will always choose jump.
- Even with jump it is too close to the wall to jump in an arc

## Jump rework
- Current jump works by calculating a perfect arc to the player. That is very predictable and not super hard to dodge
- Instead now the goal is to make the slime jump into the air, move over the player, then slam on the ground
- Added a flying animation
- Now when the slime does a jump attack, it jumps into the air, flies above a player, then slams down
- Still needs balancing
- The state machine at this point is getting pretty messy, will soon need to refactor with proper FSM using Godot's node system. Each node will handle its own state
- This has improved the jump attack and made the fighting more dynamic.. I think a good idea is to add some hang above the player while increasing the speed, make it harder to dodge but telegraph when its gonna happen
- Added timer, it feels good, but have a bug where it starts the timer multiple times, so then the next jump attack it does not work - still debugging
- Turns out i forgot to enable One Shot - a property that makes a timer repeat itself over and over again if not enabled


# 5.7.2026:
## New attack - Laser beam
- Made a laser charge animation in aseprite, a beam carges between the slime's horns
- Made a new Scene called laser, where I use RayCast2D with travel speed and max distance to shoot out a laser quickly, but not instantly.
- Since raycast is not visible to the player, I added a child node line2D
- At first I calculated player position on the end of the beam charge, but that was impossible to dodge. Instead on frame where the beam is fully charged and has like 2 more frames to dissapear before shooting, I get player position which makes it more fair, and gives the player a split second to dodge
- I also added signals from Laser script to the enemy script. In laser process delta, i check if raycast has collided with anything (can be player or foreground). Then i emit signal depending on what it collided, so the enemy script can make player take damage

## Balancing
- If you constantly run its pretty easy to dodge the slam, but that makes it harder to punish. I could increase the stagger duration to make it more punishable, but for now I just decreased slam speed slightly, which makes it easier to dodge closely and punish quickly
- Increased boss size scale, which made it much more immersive, and also giving you less space do dodge around. With this i also increased player jump speed/height, because otherwise it was pretty hard to jump above the dash
- While this did not alter mechanics themselves, it did make the boss fight feel more grand and weighty. Increased jump height also made the player movement feel more free and gave the player better manouverability

## CURRENT ISSUES
TODO: FIX THE DASH FROM CORNER BUG, SLIME STOPS TOO EARLY BECAUSE RAYCAST IS TRUE AT THE VERY BEGINNIGN
TODO: LASER BEAM DOES NOT APPEAR IF YOU ARE VERY CLOSE TO THE ENEMY, PROBABLY BECAUSE IT HAPPENS TOO FAST


# 6.7.2026:
## Player refactor - State machine
- Problem: code for the enemy cube was getting pretty out of hand, which means its about time for a proper state machine
- To get the basic concept down, I started with player since it is less complex
- I made a base State script, that works like this:
	- signal switch_state that takes a State parameter and signals to the state machine which state to switch to
	- function enter state -> a function that gets executed first thing when the state is switched
	- function exit state -> a function that gets executed when the state is being switched from
	- update that takes delta -> what the state machine process function calls
	- physics_update that takes delta -> what the state machine physics process function calls

- The StateMachine class has an initial state, in most cases idle. In _ready function, i connect the signals from its children States.
- Along _process and _physics_process functions which call child update functions, it also has change_state, which just calls active_state.exit_state, changes active state to new state, and then calls active_state.enter_state
- This way I refactored idle, move, jump and attack states.
- The implementation is divided into seperate Nodes/Scripts, which makes it way more readable, and easier to debug
- It is also much more modular, which means it is easier to add new states

# 7.7.2026:
## Animation player
- Refactored player animations to use AnimationPlayer alongside AnimatedSprite2D.
- It works by using keyframes for different "tracks", which can be animations, sounds, method calls etc
- The benefit is, I can replace the awkward frame checking (if animated_sprite.frame == 4 or animated_sprite.frame == 8: hit()) by just adding a keyframe at frames 4 and 8 that calls that function.
- This is incredibly powerful and I am just scratching the surface. It will also allow me to add stuff like a flash when I get hit etc
- I also added some sounds - mainly for sword. Will probably change them later on, but currently I got a woosh for first slash, and then sword ckang sound for the final slam of the combo. 
- Also didnt find any good sounds for footsteps, so I recorded my own - added it to running animation the same way through animation player

# 8.7.2026:
## Boss refactor - Moved from prototype Cube to SlimeBoss
- Started adding first proper boss - SlimeBoss
- Added AnimatedSprite2D with all the animations
- Added AnimationPlayer to prepare it for sounds and other calls later
- Started the big refactor - State machine
- This is more complex than player animation. I needed a reference for the player, so I added an Autoload script
	- That is a script that loads automatically when the program starts
	- Added a player_node variable and assigned it to null
	- When player scene loads, it populates it with the player reference
	- Then whenever I need it, I can make a reference by just doing @onready var player: Player = Autoload.player_node

# 11.7.2026:
## State machine refactor
- Added play_animation function into enemy script, so I dont need a reference to animation_player in each state
- Added Idle, Chase and Recover states
- Idle state just means that it is idle until player gets close enough in the arena
- Added Attack state. It was a choose_attack() function that chooses an attack based on randomness and things such as current hp % of the boss.
- Because there is multiple attacks, I had to make a state machine inside an attack state - HSM (hierarhical state machine)
	- added state_finished signal to base state.gd class for inner states like attacks to signal to the parent state when done
	- first added dash attack - had issues, where it would finish the attack once fine, then it would get stuck between states.
		- turns out, since I do not disable physics process internally when out of attack state, it kept running even when out of the attack state.
		- because the end condition was true (raycast colliding), it kept changing state, making it loop between recover and chase/attack states
- Because recovery time should likely be different based on the attack, i added a recovery time parameter to the state_finished signal
- Then when finished, it saves it to the new variable in main enemy script - next_recovery_time
- Recover state then takes that amount and sets it to the timer before starting it

# 12.7.2026:
## State machine refactor - continue
- Added Beam attack
- Mostly reused logic from the prototype
- Used animation player to get_player_pos() on the right frame, as well as to change state at the end of telegraph animation into attack state
- Added laser shoot sound, also tried charge sound but for some reason it keeps dissapearing on save - gotta investigate
- Had an issue where the laser origin fired by like 30 px to the left of where it should:
	- After some investigation, the issue was that i made the Laser scene a child of BeamAttack, which is a normal Node object, not Node2D. This can cause issues.
	- Fixed it by moving it out, as a direct child of SlimeBoss
- Had an issue where the laser beam appeared to fire twice, first in some random location, then switch to the right one quickly
	- Checked target position by printing it, it all seemed fine
	- The attack was also only being called once, so that was not the issue
	- Later I noticed that the first rouge beam was always firing into the direction of the previous attack beam
	- That pointed to stale data, so i always reset it on start_cast() now, which fixed the issue

## Audio issue
- The audio issue was likely caused by my usage in AnimationPlayer
	- Usually I clicked + to add a new track - audio track, then keyframed playing value to true
	- Deleted node, re-added sound, then added it to animation player by just keyframing value instead. It works

## State machine refactor - jump attack
- Added the final prototype attack - Jump attack
- Skipped the jump animation and used fly instead
- Instead of using jump and then switching off gravity when high enough, I used Tween
	- Tween is an object that changes a value smoothly over time
	- First i disable gravity
	- I set a variable with fly_height, then set tween to move that value upward over a certain time (1s currently). Then after its done, the callback switches state to fly
- In fly state, the logic is mostly the same. Enemy gets a direction of the player, then moves that direction until it is over the player
- Then i added a timer that it hangs into the air, and timeout() then calls slam

## Health bar
- Its the point where a health bar makes sense
- I made a reusable scene, where there is a health bar, as well as a damage indicator
- I achieved this by making the damage indicator lag behind by a split second
- At start, i init it with max health of the enemy
- Then each time the enemy takes damage, it updates the value
- Also added the health bar to player, initializing it the same way
- Added damage dealing to the enemy:
	- Each damage state has its own DAMAGE value
	- Then it calls slime_boss.deal_damage(DAMAGE) to deal damage if the player is inside area 2d
- When i tested damage, i instantly died, because the check runs every tick
- To fix it, i added a timer so that player can take damage once every 0.75 seconds (for now)

## Feedback
### Visual
- Currently, its hard to tell when player or enemy gets hit
- So i went and added a flash of the sprite using Tween
- Options were either Animation player to shift modulate value to white and back, or Tween
- I decided for tween, since it is simpler (just 3 lines of code), since animation player can only play one animation at a time, which means I would need a seperate animation player just for flashing, otherwise it would cancel a whole animation
- This made the fight feel much better and more responsive
### Sounds
- To really make it shine, I added a sound effect when player gets hit
- And a satisfying sound effect when enemy gets hit
- They are different enough so the player can discern between them

# 15.7.2026:
## Dash functionality
- Made a simple 4 frame dash animation in Aseprite for player
- Added a Dash state as a sibling to other states in the Player state machine
- It works by having a timer (currently 0.3s) that runs on start, while the timer runs, player.velocity.x is DASH_SPEED (currently 500), then when timer runs out velocity.x becomes 0 and state goes back to idle or move
- Added so that you can get into state Dash either when idle, moving or jumping
	- For idle, I had to add a helper function to get the current direction player is looking at. I did that by checking if animated_sprite.flip_h is true or false, to know in which direction to dash
	- For move, it was pretty straight forward
	- For jump, I disable gravity and set player.velocity.y to 0, so that dash is perfectly horizontal
- It works well, but now the dash is obviously OP. So next thing is a dash cooldown

### Dash cooldown
- Added a timer to the player scene called DashCooldown
- For now 3 seconds
- To track, I added start_dash_cooldown() which flips a flag dash_available to flase, and starts a timer
- When timer timeouts, it flips dash_available back to true
- Then, in whichever state you can dash, i added "and player.dash_available" to the condition

## Slime jump attack bug
### Problem
- When the slime flies up, if you are directly underneath and try to move at the right time, you can make it choose the opposite direction, which makes it never reach above you, essentially making it stuck unless you move below it
### Solution
- Currently, fly_above_player() function in Jump attack state was only called once on state change.
- The solution was to move it into physics_update(), so that the direction updates every tick when the Substate.FLY is true

## Balancing post dash
### Problem
- With dash available, the slime boss becomes pretty easy.. you can dodge the jump attack slam easily now
### Solution
- Decreased tween flying time from 1s to 0.75s - makes the player not spam dash when they dont need it, as the attack happens faster, there is a greater chance they wont have the dash if they wasted it
- Increased SLAM_SPEED from 600 to 670 - makes the reaction window with dash a little harder
- Increased the FLY_SPEED from 300 to 350 - similar thing as with flying time, the whole attack lasts less time, meaning the player cant use dash willy nilly
- Increased dash speed from 650 to 700
- Increased dash cooldown from 3s to 4s

## Fixes
- Added a window of invulnerability while the player is not visible during a dash
- This makes last moment dashes possible, and makes the precision better, as the player does not take damage mid dash when there is no player model
- I achieved that using animation player and an "invulnerable" flag, which i flip on certain frames
- Inside take_damage function, i put everything under if !invulnerable clause

# 19.7.2026:
## Player attack collision shapes
- Before, I used the same rectangle collision shape for both hits in combo attacks, meaning neither was very accurate to the animated attack shape
- I replaced that single collision shape with two seperate polygon collision shapes, and mapped them out to the attack shape exactly
- I then replaced the attack hit logic with a function for each attack
	- Instead of using signals to signal to the main script, I added the slime boss to a group "enemy", then inside each hit function, I check if there is a body inside the area2d, and if that body is of group "enemy"
	- On attack state enter, I enable hit 1 collision shape and disable hit 2 collision shape
	- Then after first attack hits, I disable 1 and enable 2
	- After 2nd attack hits, I disable 2 as well
	- If the attack is interrupted, I also added exit_state function where it disables both on state exit either way
- This has cleaned up the code more, made the hits more reusable (since now I only need to add the new bosses to the "enemy" group), and I dont need to have attack code split up across multiple files
- Also adjusted so that the first hit does 5 damage (previously 10) and 2nd one does 10, since first one is a slash, while 2nd one is a slam

# 22.7.2026:
## Slime boss - Rain attack
- All the attacks so far were pretty direct - you had to dodge the slime boss, except the laser which was also pretty straight forward
- So i decided to add something more dynamic - a rain attack
- The way it works:
	- It is essentially an enhanced version of the jump/slam attack with an added step
	- It jumps/flies into the air
	- Then it moves left and right between walls for a certain amount of time (currently 5 seconds)
	- During that time, it drops balls/drops of slime that damage the enemy if they fall on him
		- For that, I made a new scene called SlimeRain - the base node is Area2D, it also has an animatedSprite2D and a collision shape
		- Inside the script for that scene, it just has gravity work on it, and 2 basic animations - fall and hit
		- When the slime drop collides with an enemy, it deals damage and instantly gets despawned
		- When it hits the ground, it plays the hit animation (basically splash) during which if a player walks over it, it can still damage him
		- After the hit animation is finished, it despawns
	- When the timer for the slime rain is up, it goes into fly mode, where the usual jump attack continues - it moves above player and slams down
- I decided to replace the jump attack with this one after the boss drops below 50%. This makes the attack feel newer and it takes the player less time to adapt to it

## Misc
- Added sounds to slime drops hitting
- Reduced player dash cooldown to 2.5s

# 25.7.2026:
## Bug fixes
- If slime boss did the jump attack and landed on one of the "steps", he would get stuck in the slam
- With debugging by seeing collision shapes and ray casts, i found that the step is too small for the bottom two raycasts to see if its on the edge
- Moving it out further towards the corner solved the issue

## Shaders
- I needed a way to signal to the player that the dash is ready
- I tried to first use tween with color change, like I had for taking damage flash - but that proved to be hard to make noticeable, as it just makes the current colors brighter, and since the character is mostly black, it is barely noticeable
- Thats where I realized i have to learn basic shaders
- Godot uses gdshader for shaders - much easier than usual shader languages
- For my intents and purposes, I only needed fragment function 
	- The function runs for every pixel
	- So i had to filter the pixels by alpha value using a simple if statement
	- Then i assign a color to that pixel
	- To not always have it colored that way, I use flash_amount which is a range between 0 and 1
	- That value is uniform, which means i can change it from gdscript
	- Then i use mix to apply that value to the pixel (if 0 its transparent, if 1 its visible)
	- Then in gdscript I use tween to move that value and also choose color
	- I did the same for damage (white flash) and when the dash recovers, green
- Applied the same to the enemy boss

# 27.7.2026:
## New heavy attack for the player
- Over the weekend, I animated a new heavy attack - a sword draw slash
	- It has a long wind up, and a punishing recovery
	- Deals a lot of damage
	- High risk, high reward move
- Added a new state HeavyAttack, works mostly the same as the light/combo attack, except you cannot interrupt it with a jump, and you can only start a heavy attack while in idle or moving state
- Added a new heavy attack area with a polygon that matches the attack area shape
- Found two cool sounds - electricity crackling for the power up aura, and sword clash for the slash itself
- Wired everything up inside animation player

### Bug fix
- Had an issue, where the new attack hit did not register
- Checked debug collision shapes, and I noticed that it was not rotating/flipping when the player turns around
- Added the flipping code, but then i noticed that not even the other area2d shape flipped correctly.
- The position changed, but the shape itself did not mirror itself
	- Fixed that by adding area2d.scale.x = 1, area2d.scale.x = -1
	- By doing that, it now flips over properly, and is now accurate and consistent no matter which direction you face

### Findings
- With the introduction of a new attack, the boss needs more balancing to be challenging but fair with the player's kit
- I also need to further fine tune player's kit, and the enemy slime, so that the player has a reason to use one attack or the other, and spamming just one is a bad idea
- With this realization, I need to complete the player's kit first, before moving on to boss #2. Lock it in by end of boss #1 development

# 1.8.2026:
## Slime boss jump and rain attack improvement
### Attack adjustments
- The jump attack, and by extension the rain attack was pretty easy to dodge and punish because it was pretty simple
- To solve that, I decided to add some AOI damage to it on the slam - which makes sense because it is a slam
- I added an energy blast to the landing animation, as well as a new area2d for it
	- Since the blast is moving outward, and area 2d is static, to make it as fair as possible, I make it deal damage somewhere in the middle of the animation, when the blast is most of the way expanded already
- This makes punishing the simpler jump attack more threatening, as you gotta dodge further, giving you less time to deal damage, as well as less room for error
- Since the area2d spans the whole width and some more, I reduced the slam damage if it jumps directly on top of you to 50, as the damages stack.
- The AOE only deals 20 damage
- To make it a little more unpredictable, forcing the player to play a bit safer, I added a randomized slam timer (the amount of time it hangs in the air before slamming down) between 0.05 and 0.5s

### Slow down
- With slime rain, it makes sense that as the player gets hit, he gets slowed down briefly
- Added current_speed variable in player script, which by default is SPEED const
- On hit with slime rain, I call player.slow_down(), which sets the speed to SPEED/2 and starts the timer (0.75s)
- On timer timeout, resets the speed back to normal
- To not make the player moonwalk during that time, I also slow down the run animation to half speed

## Balancing
- Removed ability for player to dash mid air - makes the player more careful about when to jump and when to use dash

## Misc
- Added health bar borders

# 2.8.2026:
## Sounds
- Added more sounds for both enemy and player - jump, dash sounds, slam sound
- Jump and dash use the same sound, except dash is a higher pitched woosh sound

## Player kit
- Before, the player could interrupt the combo attack with a jump, which was buggy (you could attack cancel a jump, then jump cancel an attack and basically fly) and made the attack pretty spammable
- So i killed two birds with one stone - made it only interruptable with a dash, which itself has a cooldown, so you cant just spam combo and cancel it whenever you want

### Player combo attack rework
- So far, the player light attack combo was a 2 hit attack treated as one attack.. Most games in this genre seperate the combo attacks into individual clicks
- So, I added recovery animation for hit 1, and implemented it so the first click only does that one attack
	- If a player clicks the attack button again during first combo, or during recovery, then the second part of the light combo continues
- This gives the player more options for attacks, he can just poke with first low damage part without committing to the full combo (or having to interrupt)
- For the first boss, this isnt that much of an issue, but 2nd boss will likely have parry, so there it will matter a whole lot more - requiring skill and preventing spamming, instead of being committed to a combo

## Shader
- Added opacity value to shader, so that the dash flash opacity can be less

## New slime state - Death
- Added a death state, which activates on health <= 0, plays an animation and sound, and then despawns

## Balancing
- Made recovery times on dash attack and beam attack way lower - like 0.2s roughly.. this makes player have less opportunities to punish, and makes punishes more risky
- Overall, it makes the fight more fluid.. More dodging, less standing around and attacking

# 8.8.2026:
## Player adjustments
- Player could currently turn around mid attack, which isnt the intended behavior
- Because the player flipping logic is within the player script itself, I decided to just wrap the flip function conditional with an if statement that checks whether the player is in attack state
- Because 4 states are attack states, I added them into a group "player_attack", then just check if the current state is not in "player_attack" group

## Slime boss adjustments
### Rain attack
- Currently, the rain attack during the actual dropping of slime blobs was timed - 5 seconds. That meant, that it depended when it would stop dropping slime on the timer and not position, meaning that it was somewhat randomized
- To make it consistent, I instead check the amount of times it bounces off a wall
	- When it hits the target bounce amount, and is close enough to the player on the final pass, it stops dropping slime for the last little bit
	- This makes it consistent, but makes it harder to dodge since it doesnt mean the player has a lot of time between the last slime drop and the slam

## Getting ready for small testing
- As the boss moveset is complete, and player's is more or less also complete, it comes down to final adjustments and bug fixes, getting the demo boss fight ready for a small sample size of testers (a few friends) based on which I'll balance it out/fix more before moving on to the second boss
- First thing's first - I work on native 3440x1440 resolution. If i change the resolution to 1080p (which is likely the most common resolution), the UI breaks
	- That is because the current health bars are children of canvas layer on individual characters, which do not move/scale with resolution changes
	- To solve that, I will make a new UI scene to hold all the UI elements that need scaling
	- Made a new UI scene, base node is CanvasLayer. Then Control node below that, which holds each bar and its border
	- I added slime and ui nodes to Autoload, and then signal UI script on health change

# 9.8.2026:
## Controls popup
- To prepare for testing, I made a little button that opens a pop up, showing basic controls scheme
- You can click anywhere outside to close it

## Player adjustments
- Added some acceleration to make movement feel less robotic
- Added new state - Dead. Added animations for it
- When health reaches 0, state changes to Dead, which just plays the death animation with sound effect, then when its done, it restarts the game
- This also prevents player from moving
- I also added a guard (if state_machine.active_state = dead_state) so that the sprite cant be flipped when dead

## Sounds
- Added more sounds. Growl sfx when enemy is idle, background music on repeat, death sound effect

## Slime jump/rain attack adjustments
- I noticed that if i stand in a corner, it would not slam down. When calculating if the slime is above player, I basically checked if global position of the slime on x axis is about the same (+-8) as the player. So i increased that to 32, which fixed the issue, but that then introduced a new issue - the slime would stop and slam too soon, nearly missing the player everytime
- To solve this, I had an idea to also make it a little harder to dodge - randomize the amount of time it keeps moving from when it detects as above the player
	- I randomly generate a value between 0.02 and 0.1, and then start a timer with that value. When the timer is over, only then does it stop and transition into slam
	- This solved the issue, and made it a little less predictable - not to the point where its unfair, but just a little more thought has to go into where to stand when punishing the enemy
- Also, the player collision shape was slightly off center, which made the slime still not detect above player on the right side when hugging a wall. Instead of increasing the detection distance more, I centered the collision shape, and instead moved the sprite

## TESTING - PLAYER 1:
- My friend play tested the game
- Feedback/observations:
	- Did about 20 tries, the best he got to was a little below half hp
	- He almost exclusively used heavy attack
		- He said if light attack allowed movement, it would be more useful
		- While the execution and recovery is faster, the range is smaller, and damage is also less
	- Enemy dash attack is too quick/the jumping isnt high enough

### Balancing/fixes:
- Made player light attack execute faster - from 15 fps to 17 fps
- Improved damage from 5 + 10 damage to 7 + 14 damage. Meaning it does almost the same damage as heavy, but much quicker
- Increased the enemy dash telegraph timer from 0.75s to 0.85s to make it a little less punishable
- To further make the light attack more mobile, I added moving at 1/5 the usual speed, as well as re-enabled turning around/changing directions during light attack combo
- Also slightly increased jump speed from -275 to -285

# 16.8.2026:
## Player balancing
- I did not really like how being able to move while attacking worked - instead, I implemented a simple pre-programmed movement into the attack
	- Basically, inside enter_state() of combo attack states, I set player velocity x to certain number, then inside physics_update, I move it towards 0 at a certain pace
	- This makes combo attack feel more like it does in other similar games
- Decreased dash timer from 2s to 1.75s
- Further increased framerate (animation speed) of combo attack animation from 17 to 18 fps

## Slime boss balancing
- Since this is an introduction boss, it would need some overall nerfs - mainly with dash attack
	- I decreased the dash speed from 700 to 680
	- I increased telegraph timer for dash attack from 0.85s to 0.9s
	- Increased rain timer from 0.22 to 0.24s (meaning the rain drops are further apart, making it easier to dodge)

## WITH THIS, FIRST BOSS FIGHT IS DONE - BEHAVIOR TREE TIME

# 3.9.2026:
## Reaper boss
- Made a new main scene for the 2nd boss by duplicating first scene, and removing slime boss node
- Made a new ReaperBoss scene, added a basic script to wire up health to the UI the same way as for slime boss
- To make health bar work for all types of enemies, I replaced slime_boss_node in autoload with a basic boss_node, that whichever boss is loaded populates
- Added an animated_sprite_2d and collision_shape_2d to the boss, then added it to the main scene
- Added flash shader when taking damage

# 6.9.2026:
## Behavior tree
- Started making the actual behavior tree
	- Added base node scripts:
		- BTNode (behavior_tree.gd)
		- Composite node
		- Leaf node
		- Selector node
		- Sequence node
	- Then added Selector node as the base Behavior Tree node in the boss scene
	- Added Sequence attack as the first child, with 2 leaf children:
		- ConditionInRange that checks if the player is close enough to the enemy for the attack
		- ActionAttack that executes the actual attack
- I had an issue where reaper boss autoload node would not be populated when it is required in tick() of behavior tree
	- Turns out, godot loads _ready() of children first, so it was not populated yet at the right time
	- The solution was to use _enter_tree() which does it at the very start
- Added SequenceChase sequence node as a sibling to attack, with ConditionInSight and ActionChase as leaf nodes
- Since the BT executes left to right (or in this case, top to bottom), Attack sequence is first, if the distance condition fails, then it goes to chase

# 7.9.2026:
## BT fixes
- Currently, the BT was very bare bones (still is) - the boss would come to you, attack once (just play the animation) and that was it.. then it was stuck
- I added an Idle action to the far right (bottom) of the BT, so if it doesnt attack or chase, it idles
- I added an end condition to ActionAttack - when the animation ends, it returns Status.SUCCESS, and resets flags, so that next time it can re-do the attack normally
- It used to get stuck at the last frame of the attack animation, the fix was to call animation_player.stop() before every boss.play_animation()

# 9.9.2026:
## Reaper Boss
### Combo attack
- Added an area2d with collision polygon 2d
- Added deal_damage() function to the ActionAttack leaf, following the same logic as for the player: if body is in attack_combo_area and that body is in group player, then body.take_damage()
- Added area2d flipping and scaling based on direction
- Added ActionRecover leaf to the ComboAttack sequence
	- It plays idle animation, and starts a timer, timer sets a flag finished, when flag finished is true, it returns SUCCESS
- Improved attack by adding small lunges forward when attacking, makes it more dynamic
	- I added a apply_lunge() function, which checks direction based on which was the sprite is facing, then applies direction * LUNGE_SPEED
	- apply_lunge() is called in animation_player at the correct frames
	- Then I added decceleration to the tick function, by using move_toward, which moves a value (velocity) to a value (0) in increments (DECCELERATION_SPEED)

# 12.9.2026:
## Reaper boss improvements
### Bug fix - direction facing
- Because the boss checks just the distance to the player every combo, you could stand behind it close enough, and it would attack in the wrong direction
	- To fix that, I added another check, check_if_right_direction(), which checks which way the sprite and area2d is facing, which direction is the player, if it doesnt match, it flips the sprite to the player direction
	- To prevent it from flipping mid combo, i only do it once when ActionAttack starts

### Blackboard
- Since this boss will be more complex, it will need to track multiple values. To prevent myself from repeating same checks in every leaf node, I implemented a simple Blackboard - a shared dictionary with keys and values, so that I can read all of those values from all boss leaf nodes
- For now, I added player, boss and distance_to_player values

### Stamina
- When I was doing the slime boss and comparing it to Nine Sols bosses, I found that my boss felt very monotone, even though it had the same amount of moves
- Upon further analization, I noticed that those bosses behave differently: they attack for a while with multiple attacks and combos, then give you an opening for a few seconds
- To make my 2nd boss follow that similar formula, I added a stamina system:
	- The boss has max and current stamina, currently 100 being max
	- Whenever the boss uses an attack, it costs stamina
- To define the stamina cost and also future data for attacks, I made a base class AttackData that extends Resource class, and then I can make a resource file for each attack with stats such as damage, stamina cost, and in future also range, and maybe some other ones
- I added a way to recover stamina by adding a new selector, at the very start, that checks if the stamina is below threshold (will add more complexity later), then it starts that sequence, which is basially the boss walking slowly and recovering stamina before continuing to attack - that gives player an opening
	- However, I after it recovers, the attack combo sequence is bugged out
	- After lots of debugging, the issue was that when the stamina was 20, and attack costs 20 stamina, when attack used stamina up, on the next tick, the tree went straight into recovery, without letting the attack finish, which left a stale state in attack branch
	- I fixed it by adding a boss_is_attacking flag in blackboard, which I set to true right before consuming stamina, and set it back to false right before exiting recovery after the attack
- I added green flashing each time stamina is recovering to indicate to the player the boss isnt just bugged out, but recovering
