# cppToUML
Convert C++ files to plantuml

## Usage:
Test the script from the git repo-root by running it with file input:

```
perl -Ilib cppToUML.pl example/\*
```

or piped input

```
cat example/* | perl -Ilib cppToUML.pl
```

Any of the methods can be combined with plantuml to generate a png by adding an extra pipe

```
cat example/* | perl -Ilib cppToUML.pl | plantuml -pipe > example.png 
```

Where -Ilib is needed to find the StoreClass module. The end result of the above command is:

[[https://github.com/nordbergjohn/cppToUML/example/png/example.png|alt=plantuml]]


## Assumptions
Classes/structs and their member parameters and functions all start on a newline with 0 or more space/tab indentation.
The occurence of `};` on an empty row is interpreted as *done parsing current class*.

A class or struct followed by `:` is parsed for inheritance until reading an opening brace.

## Covers the following cases

- [x] Single line member functions
- [x] Single line member variables
- [x] Nested classes
- [x] public, private and protected access modifiers.
- [x] Multiline inheritance
- [x] Multiline comments using `/**/`
- [x] Multiline member functions
- [x] Multiline member variables
- [x] Template member functions
- [x] Template classes
