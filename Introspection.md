# Introduction #
While not the primary consern, the console has some rudimentary commands for navigating the structure of your application at runtime. This includes objects, DisplayObjects, variables and methods.

## The scope ##
Internally, the console currently refers to the object it is currently looking at as its "scope". For instance, the initial scope of the console is the object it is parented to, say, your Main class `object [Main]`.

### Changing the scope ###
There are a few ways to change the current scope.
If you are familiar with a disk system tree structure, imagine it as going up or down a tree. Going up means choosing one of the available branches and moving to it. Going down means returning to the parent branch of the branch you're currently on.

An up-branch can be any child object of the current scope, such as a display object, variable, function, you name it. A down-branch is only accessible if the current scope is a DisplayObject, and points to the parent display object.

### Inspection commands ###
**select _name_**
Sets the named property or child of the current scope as the new scope

**back**
If the current scope is a DisplayObject, set the current scope to its parent

**root**
Sets the current scope to the stage the console is on

**children**
List the available displaylist children of the current scope

**scopes**
List the available scopes within the current scope (includes display children and complex types)

**complex**
List the complex types (objects, classes) held in variables on the current scope

**variables**
List the variables of the current scope , as well as their values

### Scope interaction commands ###
**set _property_ _newvalue_**
If the current scope is a sprite, `set scaleX 1.5` will do exactly what you expect.

**get _property_**
Returns the current value of _property_ on the current scope

**call _methodname_ _...args_**
Will attempt to call _methodName_ on the current scope with the supplied arguments


### Byte arrays ###
**hexDump _address_ _length_**
If the current scope is a byte array, dump the byte array to the console.

Dumps are displayed in a paged fashion, with a default start address of zero and a page size of 256 bytes.  Repeated calls will dump additional pages to the console, incrementing the start address as it goes.  A start address and a page length can optionally be specified.  Decimal, octal (with leading "0") and hexadecimal (with leading "0x") values are all accepted.

### Controllers ###
**createController _...properties_**

A controller is a specialised GUI window that contains a table of property names and their values. The value fields are editable, and work like setters in that changing them changes the property they target instantly. Typically, controllers are used to make it easier to change DisplayObject properties on the fly for testing different visual adjustments, but can also target other objects.

To create a controller, use the `createController` command, and append any propertynames of the current scope you want to adjust.
For instance, being in a displayobject scope, try `createController scaleX width`.