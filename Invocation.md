The default keystroke for toggling the console is shift+enter, but you are free to change this to any combination of held down keys.

To do this, use the setKeyboardShortcut method of the ConsoleUtil class.

```
public static function setKeyStroke(keystroke:uint, modifier:unt):void
```

Example use:

```
//The default keystroke
ConsoleUtil.setKeyboardShortcut([KeyBindings.ENTER,KeyBindings.CTRL_SHIFT]);
//Quake style
ConsoleUtil.setKeyStroke(KeyBindings.toKeyCode("|"),KeyBindings.NONE]);
```

### Ruleset for keystrokes and Modifiers ###


#### Valid modifiers: ####

  * KeyBindings.NONE
  * KeyBindings.ALT
  * KeyBindings.CTRL
  * KeyBindings.SHIFT can only be used as a modifier in conjunction with an another modifier + a third keystroke
  * KeyBindings.ALT\_SHIFT or ALT + SHIFT
  * KeyBindings.CTRL\_ALT or CTR + ALT
  * KeyBindings.CTRL:SHIFT or CTR + SHIFT

#### Valid keystrokes: ####

  * ALL F1, F2 and so on can only be used as keystroke with no modifiers.
  * KeyBindings.ENTER can only be used as keystroke + 2 modifiers but can not be used with ALT\_SHIFT since it is a reserved keystroke i Windows for Fullscreen.
  * KeyBindings.TAB can only be used as keystroke with ALT\_SHIFT as the modifier.
  * KeyBindings.ESC can only be used as keystroke + 1 modifier
  * KeyBindings.SPACE must have at least on valid modifier.
  * KeyBindings.UP|DOWN|RIGHT|LEFT
  * KeyBindings.NUMPAD_`*`
  * KeyBindings.CHARACTERS_`*` as long as they are valid unicode characters.
  * All valid unicode keyboard characters.

#### None valid keystrokes: ####

  * KeyBindings.BACKSPACE
  * KeyBindings.CAPSLOCK
  * KeyBindings.INSERT
  * KeyBindings.DELETE
  * KeyBindings.HOME
  * KeyBindings.END
  * KeyBindings.PAGE\_UP
  * KeyBindings.PAGE\_DOWN
  * KeyBindings.ALT
  * KeyBindings.CTRL
  * KeyBindings.SHIFT

#### Validating your Keyboardshortcut ####

To validate your keyboard shortcut use the `KeyboardManager.isValidKeyboardshortcut` method

```
KeyboardManager.isValidKeyboardshortcut(keystrokeValue, modifierValue)
```