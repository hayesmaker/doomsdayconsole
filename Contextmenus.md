Previously mandatory, application-wide context menus are now opt-in.
To include context menus in your console implementation, use the new ContextMenuUtil class as such.

```
import no.doomsday.console.ConsoleUtil;
import no.doomsday.console.gui.ContextMenuUtil;
public class Main extends Sprite{
  public function Main(){
    ContextMenuUtil.setUp(ConsoleUtil.instance, this);
    addChild(ConsoleUtil.instance);
  }
}
```

The second argument of setUp is an optional reference to your display tree root. If you only want context menus for the console itself, omit this argument.

### Air ###
The Air runtime incorporates context menus differently, and as such has its own context menu utility. The syntax is the same, but with a different class.

```
import no.doomsday.console.ConsoleUtil;
import no.doomsday.console.gui.ContextMenuUtilAir;
public class Main extends Sprite{
  public function Main(){
    ContextMenuUtilAir.setUp(ConsoleUtil.instance, this);
    addChild(ConsoleUtil.instance);
  }
}
```