# Danox Prrogramming Language Interpreter

This is a custom Lox implementation built using Dart. 

### Features

Danox currently supports:
- Dynamicly typed variables
- Print statements
- Math expressions
- Conditionals
- For loops
- While loops
- Nested statements

### Example

```
// A variable
var a = 1;

// Another variable
var b = ((1 + 2) / 3 * 4) - 5 / 6;

// Print
print b;

// Conditionals
if (a == 4 or (b == a and 1 == 0)) {
  print "A";
} else {
  print "B";
}

// Loops
for (a = 1; a < 10; a = a + 1) {
  print "A";
}

while (a < 20) {
  a = a + 1;
  
  print "B";
}

while (a != 100) {
  a = 100;

  if (a == 101) {
    print "B";
  } else if (a == 100) {
    print "A";
  } else {
    print "O";
  }
}
```
