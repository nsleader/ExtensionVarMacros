import ExtensionVar
import ObjectiveC

class TestClass {
}

extension TestClass {
    static var test_objc_key: UInt = 0
    
    @associated(key: "test_objc_key", policy: "OBJC_ASSOCIATION_RETAIN")
    var test: Int?
}


var inst = TestClass()
inst.test = 5

print(inst.test)
