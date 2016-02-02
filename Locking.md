The `Console` can be locked such that only a **keyboard sequence** or **secret password** is the only way to unlock and toggle on the `Console`.
This is useful when embedding the `Console` as a _extra utility__in a **production mode application** that is not readily available to the end user._


#### Using a secret ####

```
  ...
  addChild(ConsoleUtil.instance);

  // Now lock the Console with the secret.
  var secret:String = "Mega1234!!";
  ConsoleUtil.lock(secret);
```


#### Using a keyCode sequence ####

```
  ...
  addChild(ConsoleUtil.instance);

 // Now lock the console with the Konami Code
  var keyCodes:Array = [ KeyBindings.UP, KeyBindings.UP, 
                         KeyBindings.DOWN, KeyBindings.DOWN, 
                         KeyBindings.LEFT, KeyBindings.RIGHT, 
                         KeyBindings.LEFT, KeyBindings.RIGHT, 
                         KeyBindings.a, KeyBindings.b ];
  ConsoleUtil.lockWithKeyCodes(keyCodes);
```


#### Note ####

_The functionality described above is not intended to be used when the console is already toggled on, it is meant to be used when `Console` is being added,
and should not be visible or available directly to the end user._