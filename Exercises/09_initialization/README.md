# Initialization

This section covers how Swift sets up new instances of a type: custom
initializers, failable initializers, and the rules for classes.

## Official Swift Documentation
- [Initialization - The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization)
- [Failable Initializers - Swift Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization#Failable-Initializers)
- [Class Inheritance and Initialization - Swift Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization#Class-Inheritance-and-Initialization)

In this section, you'll learn about:
- Custom initializers that validate or transform their inputs
- Failable initializers (`init?`)
- Designated and convenience initializers for classes
- Required initializers and inheritance

## Key Concepts

### Designated vs convenience
A designated initializer fully sets up an instance. A convenience initializer
must call a designated one through `self.init(...)`, rather than setting stored
properties itself.

### Failable and required
`init?` returns nil when the inputs are invalid, which is handy for parsing.
`required init` forces every subclass to provide that initializer.

## Further Information

- [Initializer Delegation for Class Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization#Initializer-Delegation-for-Class-Types)
- [Required Initializers](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization#Required-Initializers)
