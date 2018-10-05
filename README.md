# cppToUML
Convert C++ files to plantuml

## Usage:
perl cppToUML <1 to N c++ source files>

With a repo at '/repo/example' an UML png of all classes in that directory could be generated like this:

perl cppToUML /repo/example/\* | plantuml -pipe > example.uml 

## Assumptions
Class parsing starts on a line with any amount of whitespace prior to the class or struct keyword.
The occurence of `};` on an empty row is interpreted as *done parsing current class*, as shown in the example below

```cpp
class Example {  // <- Begin parsing Example
  class Nested { // <- Start parsing Nested
    int m_var;   // <- Add variable to currently parsed class (Nested)
  };             // <- Finish parsing Nested
  double m_var   // <- Add variable to currently parsed class (Example)
};               // <- Finish parsing Example
```

A class or struct followed by `:` is parsed for inheritance until reading an opening brace.
Multiline inheritance is covered when the class and `{` is not on the same line:
```cpp
struct Child : public FirstParent,    // <- Begin parsing Child, add FirstParent to inheritance
               private SecondParent,  // <- add SecondParent to inheritance
               protected ThirdParent  // <- add ThirdParent to inheritance
{                                     // <- Inheritance done, continue parsing Child
};                                    // <- Finish parsing Child struct
```

## Covers the following cases

- [x] Single line member functions
- [x] single line member variables
- [x] Nested classes
- [x] public, private and protected inheritance.
- [x] public, private and protected access modifiers.
- [x] Multiline inheritance
- [x] Multiline comments using `/**/`
- [x] Multiline member functions
- [x] Multiline member variables
- [ ] Template member functions
- [ ] Template member variables
- [ ] Template classes
