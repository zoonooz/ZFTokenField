ZFTokenField
============

iOS custom view that let you add token view inside like NSTokenField

<p align="center"><img src="https://raw.githubusercontent.com/zoonooz/ZFTokenField/master/Screenshot/ss.png"/></p>

## Installation

```pod 'ZFTokenField'```

## Usage

### ZFTokenFieldDataSource
You need to implement these in your datasource class

* ```lineHeightForTokenInField:tokenField:``` return desire line height.
* ```numberOfTokenInField:``` return number of token that you want to display.
* ```tokenField:viewForTokenAtIndex:``` return view that you want to display at specify index

### ZFTokenFieldDelegate

* ```tokenMarginInTokenInField:``` your prefered margin, default is 0
* ```tokenField:didRemoveTokenAtIndex:``` get called when user deletes token at particular index.
* ```tokenField:didReturnWithText:``` get called when user hits return with text.
* ```tokenField:didTextChanged:``` get called when user changes text.
* ```tokenFieldDidBeginEditing:``` get called when user begins edit the field.
* ```tokenFieldShouldEndEditing:``` get called to ask if the field should end editing.
* ```tokenFieldDidEndEditing:``` get called when user stops edit the field.

## Author

Amornchai Kanokpullwad, amornchai.zoon@gmail.com [@zoonref](http://twitter.com/zoonref)

## License

ZFTokenField is available under the MIT license. See the LICENSE file for more info.
