To access this functionality, enable the ProductInfoUtil plugin:
```
DConsole.registerPlugins(ProductInfoUtil);```

From this point on, tag viewing is implemented via the **productInfo** command.

SWFs compiled with Flex Builder or the  Flex SDK include an undocumented ProductInfo tag that specifies, among other details, the SDK version used in the application, and the compilation date of the SWF.  These details can be particularly useful if you are working with multiple versions of a Flex application and need to quickly determine when a particular SWF was compiled and the SDK version used.

Note that this tag is typically found only in SWFs compiled with Flex, and not those built from the Flash IDE or other tools.  If your SWF does not contain a ProductInfo tag, the console will report that such details are not available.

For more information on this tag, see Claus Wahlers' discussion of [Undocumented SWF Tags written by MXMLC](http://wahlers.com.br/claus/blog/undocumented-swf-tags-written-by-mxmlc/).