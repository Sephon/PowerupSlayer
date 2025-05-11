# Vampire Survivors-style Game

A top-down survival game built with Godot 4.2 where you fight endless waves of enemies.

## Setup

1. Install Godot 4.2 or later
2. Clone this repository
3. Open Godot and import the project
4. Place the following assets in their respective directories:
   - `res://Tilesheet/medieval_tilesheet.png` (64×64 tiles with 32px margin/spacing)
   - `res://Sprites/Actor.png` (64×93 player sprite)
   - `res://Sprites/Spider.png` (40×37 enemy sprite)

## Project Structure

```
scripts/
├── map/
│   └── map.gd           # Tilemap generation & chunk loading
├── player/
│   ├── player.gd        # Player movement & weapon slots
│   └── controls.gd      # Input handling
├── enemy/
│   ├── enemy.gd         # Basic enemy AI
│   └── spawner.gd       # Enemy spawning system
├── weapon/
│   ├── weapon_base.gd   # Abstract weapon class
│   └── bullet.gd        # Basic bullet weapon
├── scene_setup.gd       # Programmatic scene creation
└── project_init.gd      # Global initialization
```

## Running the Game

1. Open the project in Godot
2. Add `project_init.gd` as an autoload in Project Settings
3. Run the `scene_setup.gd` script once to generate all scenes
4. The game will automatically start with the generated scenes

## Controls

- WASD: Movement
- Gamepad Left Stick: Movement (with deadzone)
- Weapons fire automatically at the nearest enemy

## Features

- Procedurally generated infinite map with chunk streaming
- Enemy spawning system that keeps enemies just outside the viewport
- Weapon system with support for multiple weapon types
- Basic enemy AI that seeks and attacks the player
- Health system with damage handling

## Scene Generation

The game uses programmatic scene generation instead of manual scene setup. The `scene_setup.gd` script:

1. Creates the main game scene with all necessary nodes
2. Generates the player scene with sprite and collision
3. Creates the enemy scene with AI and collision
4. Generates a simple bullet scene for the basic weapon
5. Saves all scenes to disk for future use

To regenerate scenes, simply run the `scene_setup.gd` script again "# PowerupSlayer" 
