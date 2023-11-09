// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Макрос позволяет использовать свойства в экстеншенах класса.
///  - Parameters:
///     - key: Имя статической переменной для ассоциативного сохранения
///     - policy: Политика ассоциативной ссылки (`OBJC_ASSOCIATION_ASSIGN`, `OBJC_ASSOCIATION_RETAIN_NONATOMIC`, `OBJC_ASSOCIATION_COPY_NONATOMIC`, `OBJC_ASSOCIATION_RETAIN`, `OBJC_ASSOCIATION_COPY`)
///
/// Используется только в расширениях класса! Свойство должно иметь опциональный тип.
/// ```
/// extenstion UIView {
///     @associated(key: "test_objc_key", policy: "OBJC_ASSOCIATION_RETAIN")
///     var someProperty: Int?
/// }
/// let view = UIView()
/// view.someProperty = 5
///
/// ```
///
@attached(accessor)
public macro associated(key: String, policy: String) = #externalMacro(module: "ExtensionVarMacros", type: "ExtensionVarMacro")
