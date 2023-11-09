# ExtenstionVar

Макрос позволяет использовать свойства в экстеншенах класса.

Используется только в расширениях класса! Свойство должно иметь опциональный тип.

## Пример

```swift
import ExtensionVar
import ObjectiveC

extenstion UIView {
static var someProperty_key: UInt = 0

@associated(key: "someProperty_key", policy: "OBJC_ASSOCIATION_RETAIN")
var someProperty: Int?
}
let view = UIView()
view.someProperty = 5
```
