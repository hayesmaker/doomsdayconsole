## Whosawhat now? ##
DConsole is a box of utilities for interacting with your application at runtime, primarily taking the form of an output textfield and an input textfield. The output field doubles as a trace window, and is your source of feedback. The input field is how you primarily interact. You type in commands, built-in or custom, and watch the effects take place.

It works by sitting on top of the rest of your application, crawling your ActionScript objects, their properties and children, and letting you change their variable values, call methods and so forth.

## How do i implement it? ##
A singleton utility, DConsole, lets you access and write to the console from anywhere in your application, as well as link methods to custom console commands for testing with various arguments. To get started, simply `addChild(DConsole.view)` at your root, and you're off.

## Won't it mess around with the rest of my application? ##
Absolutely. That's what it's designed for! But, seriously, while keeping the console footprint as small as possible has been a prime concern, it still does add a fair chunk of k's to your application size, and is likely to incur slight performance penalties.

Generally speaking though, beyond practically demanding stage align and scalemode be set to top\_left and no\_scale, the console won't touch anything else you might do, and never will. Until you ask it to. It should also never interfere with the garbage collection passes through your app. Internal references to objects are commonly stored as temporary and weak references.

## Is it deploy ready? ##
Ideally, deployed solutions will not contain an instance of the console, as it constitutes a pretty serious security risk, allowing endusers intimate access to the application data.

The recommended procedure is to remove the console altogether from release builds. It will, however, not break your app or change its behavior, so if security is less of a concern, you needn't worry.

## What constitutes a "command"? ##
A command is simply a bit of text pointing to an action you want to carry out. For instance, typing in "clear" and hitting the enter key will clear the console message buffer, removing all its content.

Custom commands are created with `DConsole.createCommand("triggerword",myFunction)`. Consequently, typing in "triggerword" and hitting enter will call myFunction. If myFunction has arguments, typing "triggerword myArgument myOtherArgument" will attempt to call myFunction with those arguments.

## But I hate typing! ##
The console incorporates fast, aggressive auto-complete for object names, commands and properties, as well as a persistent command history maintained through a shared object. You will love this when you need to test series of commands you already put in the previous session.

## I still don't get it. Why shouldn't i just use MonsterDebugger? ##
If you don't "get it", then it's probably not for you in the first place. The goal of this project is not to make a be-all debugging solution. The primary goal is to let users avoid having to create custom GUI every time they want to test a method with different arguments. Here are examples of ways in which i've used it to date.

  * Trying various image URLs with an image gallery to see if scale and layout automates correctly
  * Passing arguments to a socket connection to test connectivity and remoting
  * Adjusting tween times alongside an AD without having to recompile
  * Adjusting pixel position, rotation and scale of display objects alongside a designer without having to recompile
  * Changing game agent states at runtime to test various conditions
  * Changing application states under various conditions to make sure it doesn't break
  * Reloading site XML content descriptors at runtime, letting me compare documents and make changes to documents without having to recompile to test them.

### Come prepared! ###
This is more of a canvas than a truly complete tool. You need to add commands yourself to make it truly useful. Also, by its nature, this is not a particularly intuitive tool. You type in words to execute commands, and it requires a developer's understanding of a Flash application. Designers will hate it. For most users, this is not a fast way to work. However, if you are working on medium sized applications, and need to test things like multiuser functionality, remoting, game behaviors or otherwise need a frontend with which to interact with your application without having to put big temporary buttons on your stage, this is where it's at.