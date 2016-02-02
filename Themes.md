# Introduction #
If you wind up using the console a lot, you might find issue with the color schemes chosen. Fear not, there are a couple of methods for changing just about every single color.

# Details #
### To change font colors ###

```
ConsoleUtil.instance.setTextTheme(
  input:uint, //The input text field color
  oldMessage:uint,  //The color of old messages
  newMessage:uint, //The color of the latest message
  system:uint, //The color of System messages
  timestamp:uint, //The color of the optional timestamps
  error:uint, //The color of error messages
  help:uint, //The color of the text in the tooltip field
  trace:uint) //The color of trace messages
```

### To change chrome colors ###

```
ConsoleUtil.instance.setChromeTheme(
  backgroundColor:uint, //The background color
  backgroundAlpha:Number, //The background alpha
  borderColor:uint, //The input field border color
  inputBackgroundColor:uint, //The input field background color
  helpBackgroundColor:uint) //The tooltip field background color
```