# cppToUML
Convert C++ files to plantuml

## Usage:
Test the script from the git repo-root by running:

```
perl -Ilib cppToUML example/\* | plantuml -pipe > example.png 
```

Where -Ilib is needed to find the StoreClass module.

## Assumptions
Classes/structs and their member parameters and functions all start on a newline with 0 or more space/tab indentation.
The occurence of `};` on an empty row is interpreted as *done parsing current class*.

A class or struct followed by `:` is parsed for inheritance until reading an opening brace.

## Covers the following cases

- [x] Single line member functions
- [x] single line member variables
- [ ] Nested classes
- [x] public, private and protected inheritance.
- [x] public, private and protected access modifiers.
- [x] Multiline inheritance
- [x] Multiline comments using `/**/`
- [x] Multiline member functions
- [x] Multiline member variables
- [x] Template member functions
- [x] Template member variables
- [x] Template classes
