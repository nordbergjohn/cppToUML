# cppToUML
Convert C++ files to plantuml

## Usage:
perl cppToUML <1 to N c++ source files>

## Assumptions
Class parsing starts on a line with any amount of whitespace prior to the class or struct keyword.
The occurence of `};` on an empty row is interpreted as *done parsing current class*, as shown in the example below

```cpp
class Example {  // <- Begin parsing Example
  class Nested { // <- Start parsing Nested
    int m_var;   // <- Add variable to currently parsed class (Nested)
  };             // <- Finish parsing nested
  double m_var   // <- Add variable to currently parsed class (Example)
};               // <- Finish parsing Example
```cpp

A class or struct followed by `:` is parsed for inheritance until reading an opening brace.
Multiline inheritance is covered when the class and `{` is not on the same line:
```cpp
struct child : public FirstParent,    // <- Begin parsing Child, add FirstParent to inheritance
               private SecondParent,  // <- add SecondParent to inheritance
               protected ThirdParent  // <- add ThirdParent to inheritance
{                                     // <- Inheritance done, continue parsing child
};                                    // <- Finish parsing Child struct
```cpp

## Covers the following cases

- [x] Single line member functions
- [x] single line member variables
- [x] Nested classes
- [x] Multiline inheritance
- [ ] Multiline comments using `/**/`
- [ ] Multiline member functions
- [ ] Multiline member variables
- [ ] Template member functions
- [ ] Template member variables
- [ ] Template classes
