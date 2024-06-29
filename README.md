<h1 align="center">Kenny's Racing Game</h1>
<p align="center"><a href="https://akeboss-tech.github.io/ASD-final-project/">online car game</a> for advanced software development final project made with godot</p>
<p align="center">By: Akash Dubey, Bryan Ly, and Ani Tiwary</p>


![alt text](media/title.png)
[Presentation](https://docs.google.com/presentation/d/1U9Ksf2WP5arYDL5eJhNH35Hg61g0uxxh1_g_wtGVEoU/edit?usp=sharing) - [Video Demo](https://www.youtube.com/watch?v=M-2rncM2iWg) - [Live Demo](https://akeboss-tech.github.io/ASD-final-project/)

## Game Modes
- Free Practice
- vs Computer
- Two Player
- Grand Prix

![alt text](media/kenny.gif)

## How it works
Our game only has one track which we race many different kinds of cars on. The `player.gd` script is responsible for the player controls on any `VehicleBody3D` node it is attached to. There is a separate script attached to the track that keeps track of a list of cars on the track and their positions. 

### Cars (VehicleBody3D)
The car mechanics in Kenny's Racing Game are powered by Godot's VehicleBody3D and VehicleWheel3D nodes. These nodes provide realistic physics and handling for the cars, ensuring an engaging and believable driving experience. Here’s how we configured and fine-tuned these components:

1. VehicleBody3D Physics:
- Utilized VehicleBody3D for the car's main body, setting properties such as mass, friction, and suspension.
- Added VehicleWheel3D nodes for each wheel, adjusting parameters to achieve a balance between stability and responsiveness.
- Modified default values to minimize understeer and improve overall handling.
2. Sound Integration:
- Integrated sound effects that correspond to the car's acceleration and deceleration.
- Used two looped audio tracks for acceleration and deceleration, dynamically adjusting volume and pitch based on the car’s speed.
- Added background music to enhance the overall racing experience.
3. Camera Adjustments:
- Implemented a camera system that changes perspective based on the car's speed.
- Configured front and back cameras to provide optimal views during gameplay.

### Checkpoints
Using a `Path3D` drawn along the track, checkpoints are generated at regular intervals along it. Using collision objects, we can detect when a car passes through a checkpoint. This is used to keep track of the order of cars on the track and to calculate lap times.

### Computer Control
The computer cars are controlled by a `ai_driver.gd` script that is attached to each car. They also take in a `Path3D` object as the racing line that they follow. The AI is very simple and just tries to follow the racing line as closely as possible. There is a small look-ahead distance that the car tries to accelerate and steer towards. This simple approach, although it ignores other drivers, is good enough for our needs. It can even preform way better than a human player.

### HUD
Similar to two player mode, the HUD is made of a top-down camera shown on the viewport.

### Video Loading Screen
The video loading screen is a camera watching the computer go along the racing line from a top down view. This is shown behind the menu to give it a more dynamic feel.

## Two Player
The two player mode is made with two different player modes stacked on top of each other.

![alt text](media/two.png)

## Grand Prix
This mode includes a bunch of computer cars racing against each other and with the player.

![alt text](media/grand.png)

## Future Improvements
To enhance the game further, we plan to implement the following features:

- Local time-saving for lap records.
- Online multiplayer capabilities.
- Improved car models with better physics and dynamics.
- A car selection feature allowing players to choose different vehicles.
- A career mode with progression and achievements.
- Additional content, including more cars, organized code, and new maps.