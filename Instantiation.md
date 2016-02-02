The `new` command allows you to instantiate objects at run-time, returning a reference to the created instance. Advanced users can use this as a subcommand

### Examples ###

```
call addChild (new flash.display.Sprite)
```

```
select myArray
call push (new package.MyClass)
```

Arguments to the class constructor can be passed as further arguments of the command as such

```
select myTextField
call setTextFormat (new flash.text.TextFormat _sans 30) 0 10
```