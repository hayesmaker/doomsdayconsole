### Introduction ###
In addition to strings and numbers, the console accepts arrays and objects in JSON notation.
The use of these types require a modicum of effort.

### Strings with spaces as individual arguments ###
Say you have a function, `addGuy(fullname:String,age:int)}}, linking it to the command {{{addGuy`. In this case, the fullname string likely has at least one space in it. To separate the fullname argument from the age argument (and avoid the full name and age being concatenated into one string arg, which is what the console does as a last resort at an argument count mismatch), use " or ' as such:

`addGuy "Andreas Rønning" 27`

### XML ###
To supply an XML argument, simply use XML notation

`myCommand <data><node/></data>`

### Arrays ###
To supply an array argument, simply use ActionScript bracket syntax:

`myCommand [1,5,6,2]`

### Objects ###
In the same way, to supply an object argument, use JSON object notation as such:

`myCommand {"firstname":"Andreas","lastname":"Rønning"`}

You'll notice that JSON notation differs slightly from ActionScript in that it wraps property names in quotes. For more information on JSON, go to http://www.json.org

### Compound types ###
Objects can contain arrays, and arrays can contain objects. Both the array and object parsing is handled by JSON, so the two are free to be mixed. You can imagine the horror of typing out objects of this complexity, but the option is there:

`myCommand [{"myArray":[{"firstname":"andreas","lastname":"rønning"}]}]`

### Objects, xml and subcommands ###
Preparsed XML and subcommand results are currently not available for inclusion in objects or arrays. I'm busy rewriting the parser to support this.