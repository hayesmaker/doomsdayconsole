### Commands that call other Commands ###

A recently added feature is recursive commands; Commands that use command calls as their arguments. An immediate actionscript parallel is `myArray.push(myOtherArray.pop())`, and the nesting of commands is practically unlimited.

To understand how subcommands work, you must understand how the console handles function calls. Say you link a command to the function `getName()`, which returns a string. When you call that command, the console gets `getName`'s return value (if any) and that result essentially bubbles up until it finally gets printed out. What this means is that any function that returns a value can be used as an argument of any other function that accepts its return type.

This all stems from a request for the ability to use math functions as command arguments, for instance `Math.random()`. The console now has a set of utility math functions for common math operations that do nothing but return their result.

### Syntax ###

The console uses parentheses for subcommands. If you want to call another command as a command argument, wrap that command in parentheses, as such: `(myOtherCommand)`.
You are free to nest subcommands within subcommands within subcommands ad nauseam, though the readability quickly degrades.

### Examples ###

`set x (random -100 100) //same as x = randomRangeFunction(-100,100)`

`set particlecount (add (get particlecount) 10000) //same as particlecount+=10000`