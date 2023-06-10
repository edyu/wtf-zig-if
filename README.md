# Zig If – WTF is !?bool

The power and complexity of **if** in Zig

---

Ed Yu ([@edyu](https://github.com/edyu) on Github and
[@edyu](https://twitter.com/edyu) on Twitter)
Jun.06.2023

---

![Zig Logo](https://ziglang.org/zig-logo-dark.svg)

## Introduction

[**Zig**](https://ziglang.org) is a modern system programming language and
although it claims to a be a **better C**, many people who initially didn't
need system programming were attracted to it due to the simplicity of its
syntax compared to alternatives such as **C++** or **Rust**.

However, due to the power of the language, some of the syntax are not obvious
for those first coming into the language. I was actually one such person.

When I was thrown into **Zig** (by choice) for my current project, I didn’t
think twice but as my code becomes more complex, I started to be confused in
the simplest programming construct--_if_ statement.

The reason is that **Zig** happens to overload the simple _if_ statement for
many of the new concepts that underlie **Zig**’s power. Today we’ll explore the
_if_ statement in **Zig** and by the end hopefully you’ll have a better grasp
of the language.

## Basic _if_ statement

The main reason for _if_ statements to exist in any programming language is to
allow conditional processing of a typically boolean expression so that if some
condition is true, do this or else do something else.

Here is the basic idea:

```zig
// if you want to try yourself, you must import `std`
const std = @import("std");

if (true) {
    std.debug.print("hello Ed\n", .{});
} else {
    std.debug.print("hello world\n", .{});
}
```

So the above code will always print **"hello Ed"** because the condition is
true.

The following code will always print **"hello world"** because the condition is
false.

```zig
if (false) {
    std.debug.print("hello Ed\n", .{});
} else {
    std.debug.print("hello world\n", .{});
}
```

Of course that’s not very useful so let’s do a string comparison in our function

```zig
// note that strings in Zig is []const u8 which means an array o
fn dudeIsEd(name: []const u8) bool {
    // remember zig is like C, so you can’t just do name == “Ed”
    if (std.mem.eql(u8, name, "Ed")) {
        return true;
    } else {
        return false;
    }
}

// we can now call the function as a boolean expression
fn sayHello(name: []const u8) void {
    if (dudeIsEd(name)) {
        std.debug.print("hello {s}\n", .{name});
    } else {
        std.debug.print("hello world!\n", .{});
    }
}
```

Because `sayHello` will return a boolean, then you can use the function in
any `if` statement as the condition.

## Error-handling _if_ statement

Ok, let's now introduce an error in the function. One of the coolest part of
**Zig** is how it handles errors. Errors are just regular return types mostly.

The _if_ statement is overloaded for error handling. The main difference is
that now you can **capture** the error using _|err|_ in the _else_ expression.

```zig
const Error = error { WrongPerson };

// you have to declare your function will return an error by using ! in front of
// the return type which actually signals that your function will return an
// error union (union of error with your actual return type)
fn dudeIsEdOrError(name: []const u8) !void {
    if (std.mem.eql(u8, name, "Ed")) {
        std.debug.print("hello {s}\n", .{name});
    } else {
        return Error.WrongPerson;
    }
}

// handle the error just like regular boolean
fn sayHelloError(name: []const u8) void {
    // notice that dudeIsEdOrError doesn't return boolean
    if (dudeIsEdOrError(name)) {
        std.debug.print("good seeing you {s} again\n", .{name});
    } else |err| {
        std.debug.print("got error: {}!\n", .{err});
        std.debug.print("hello world!\n", .{});
    }
}

// if you want to ignore the error, use _ in the capture
fn sayHelloIgnoreError(name: []const u8) void {
    if (dudeIsEdOrError(name)) {
        std.debug.print("good seeing you {s} again\n", .{name});
    } else |_| {
        std.debug.print("hello world!\n", .{});
    }
}

```

## Mixing boolean with error-handling _if_ statement

So, how do you mix boolean and error together in an _if_ statement?

You can capture the boolean in the _if_ expression just as you were capturing
the error in the _else_ expression.

```zig
fn dudeIsEdishOrError(name: []const u8) !bool {
    if (std.mem.eql(u8, name, "Ed")) {
        std.debug.print("hello {s}\n", .{name});
        return true;
    } else if (std.mem.eql(u8, name, "Edward")) {
        std.debug.print("hello again {s}\n", .{name});
        return false;
    } else {
        return Error.WrongPerson;
    }
}

fn sayHelloEdish(name: []const u8) void {
    // notice that dudeIsEdOrError doesn't return boolean
    if (dudeIsEdishOrError(name)) |ed| {
        std.debug.print("ed? {}\n", .{ed});
        if (ed) {
            std.debug.print("good seeing you {s}\n", .{name});
        } else {
            std.debug.print("good seeing you again {s}\n", .{name});
        }
    } else |err| {
        std.debug.print("got error: {}!\n", .{err});
        std.debug.print("hello world!\n", .{});
    }
}
```

## Optional _if_ statement

Another cool thing that **Zig** introduced is optional. Optional is similar to
how many other languages handle the idea of maybe. If optional is used in the
return type it designates that a function may or may not return a value.

For many languages optional is similar to how a variable can either have a value
or be _null_. **Zig** made it so that you have to explicitly declare a variable
optional before you can assign _null_ to a variable. The way to designate
something optional is to use the question mark _?_.

Interestingly, **Zig** decided to overload _if_ statement once again to handle
the optional.

To determine whether you have a value or or in the _if_ statement, you have to
use capture again but this time you use it in the _if_ expression instead of
the _else_ expression to unwrap the optional value.

```zig
fn dudeIsMaybeEd(name: []const u8) ?bool {
    if (std.mem.eql(u8, name, "Ed")) {
        return true;
    } else if (std.mem.eql(u8, name, "Edward")) {
        return false;
    } else {
        return null;
    }
}

fn sayHelloMaybeEd(name: []const u8) void {
    // this if expression is to check whether you have a value or null
    if (dudeIsMaybeEd(name)) |ed| {
        if (ed) {
            std.debug.print("hello {s}\n", .{name});
        } else {
            std.debug.print("hello again {s}\n", .{name});
        }
    } else { // when you get null
        std.debug.print("hello world!\n", .{});
    }
}
```

## Optional _if_ statement with error-handling

So now you have boolean, optional, and error that can all be handled by _if_
statements, what if you have all three? How would you parse that?

Assuming you have the following function:

```zig
// Ed or Edward are ok but definitely not Eddie, anyone else don't care
fn dudeIsMaybeEdOrError(name: []const u8) !?bool {
    if (std.mem.eql(u8, name, "Ed")) {
        return true;
    } else if (std.mem.eql(u8, name, "Edward")) {
        return false;
    } else if (std.mem.eql(u8, name, "Eddie")) {
        return Error.WrongPerson;
    } else {
        return null;
    }
}
```

You'll have to unwrap `!?bool` from left to right in that you first use _if_
statement to unwrap the _!_ error conditional by handling the error condition
in the _else_ expression. Then, you also use the _if_ expression to unwrap the
the optional _?_ conditional. Finally, you then use another _if_ statement to
unwrap the _bool_ conditional.

```zig
fn sayHelloMaybeEdOrError(name: []const u8) void {
    if (dudeIsMaybeEdOrError(name)) |maybe_ed| {
        if (maybe_ed) |ed| {
            std.debug.print("ed? {}\n", .{ed});
            if (ed) {
                std.debug.print("hello {s}\n", .{name});
            } else {
                std.debug.print("hello again {s}\n", .{name});
            }
        } else {
            std.debug.print("goodbye {s}\n", .{name});
        }
    } else |err| {
        std.debug.print("got error: {}!\n", .{err});
        std.debug.print("hello world!\n", .{});
    }
}
```

## Bonus

I lied; well, what I meant is that _if_ can also be used as an **expression**
not just a **statement** so that you can assign the return value of _if_
expression to a variable.

It's functionally similar to the ternary _?:_ expression in many languages
such as **C**.

However, _if_ expression has many restrictions compared to the _if_
statement so use it only as a shorthand equivalent to ternary _?:_.

```zig
// greeting will be "hello"
const greeting = if (dudeIsEd("Ed")) "hello" else "goodbye";
```

Also, there is also `catch` and `orelse` to deal with error and optional
respectively for simple cases where you don't have to unwrap the value using
_if_ statements.

```zig
const is_ed = dudeIsMaybeEd("Ed") orelse false;
const not_ed = dudeIsEdishOrError("Not Ed") catch false;
```

## The End

## ![Zig Logo](https://ziglang.org/zero.svg)

Special thanks to Rene [@renerocksai](https://github.com/renerocksai) for
helping out on my **Zig** questions.
