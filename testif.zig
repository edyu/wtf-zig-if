const std = @import("std");

test "basic true" {
    if (true) {
        std.debug.print("hello Ed\n", .{});
    } else {
        std.debug.print("hello world\n", .{});
    }
}

test "basic false" {
    if (false) {
        std.debug.print("hello Ed\n", .{});
    } else {
        std.debug.print("hello world\n", .{});
    }
}

// note that strings in Zig is []const u8 which means an array o
fn dudeIsEd(name: []const u8) bool {
    // remember zig is like C, so you can’t just do name == “Ed”
    if (std.mem.eql(u8, name, "Ed")) {
        return true;
    } else {
        return false;
    }
}

// note that strings in Zig is []const u8 which means an array o
fn sayHello(name: []const u8) void {
    if (dudeIsEd(name)) {
        std.debug.print("hello {s}\n", .{name});
    } else {
        std.debug.print("hello world!", .{});
    }
}

test "test string" {
    try std.testing.expectEqual(dudeIsEd("Ed"), true);
    try std.testing.expectEqual(dudeIsEd("Edward"), false);
    try std.testing.expectEqual(@TypeOf(sayHello("Ed")), void);
    try std.testing.expectEqual(@TypeOf(sayHello("Edward")), void);
}

const Error = error{WrongPerson};

// you have to declare your function will return error by using ! in front of
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

test "test error" {
    try std.testing.expectError(Error.WrongPerson, dudeIsEdOrError("Not Ed"));
    try dudeIsEdOrError("Ed");
    sayHelloError("Ed");
    sayHelloIgnoreError("Not Ed");
}

fn dudeIsEdishOrError(name: []const u8) !bool {
    if (std.mem.eql(u8, name, "Ed")) {
        return true;
    } else if (std.mem.eql(u8, name, "Edward")) {
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
            std.debug.print("hello {s}\n", .{name});
        } else {
            std.debug.print("hello again {s}\n", .{name});
        }
    } else |err| {
        std.debug.print("got error: {}!\n", .{err});
        std.debug.print("hello world!\n", .{});
    }
}

test "test bool error" {
    try std.testing.expectError(Error.WrongPerson, dudeIsEdOrError("Not Ed"));
    try std.testing.expectEqual(dudeIsEdishOrError("Ed"), true);
    try std.testing.expectEqual(dudeIsEdishOrError("Edward"), false);
    sayHelloEdish("Ed");
    sayHelloEdish("Edward");
    sayHelloEdish("Not Ed");
}

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
        // we use if again only because return type is optional boolean
        if (ed) {
            std.debug.print("hello {s}\n", .{name});
        } else {
            std.debug.print("hello again {s}\n", .{name});
        }
    } else { // when you get null
        std.debug.print("hello world!\n", .{});
    }
}

test "test bool optional" {
    try std.testing.expectEqual(dudeIsMaybeEd("Ed"), true);
    try std.testing.expectEqual(dudeIsMaybeEd("Edward"), false);
    try std.testing.expect(dudeIsMaybeEd("Not Ed") == null);
    sayHelloMaybeEd("Ed");
    sayHelloMaybeEd("Edward");
    sayHelloMaybeEd("Not Ed");
}

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

test "test bool optional error" {
    try std.testing.expectEqual(dudeIsMaybeEdOrError("Ed"), true);
    try std.testing.expectEqual(dudeIsMaybeEdOrError("Edward"), false);
    try std.testing.expectError(Error.WrongPerson, dudeIsMaybeEdOrError("Eddie"));
    try std.testing.expect(try dudeIsMaybeEdOrError("Not Ed ") == null);
    sayHelloMaybeEdOrError("Ed");
    sayHelloMaybeEdOrError("Edward");
    sayHelloMaybeEdOrError("Eddie");
    sayHelloMaybeEdOrError("Not Ed");
}

test "if expression" {
    var dude = if (dudeIsEd("Ed")) "hello" else "world";
    std.debug.print("dude is {s}\n", .{dude});
    var dude2 = dudeIsMaybeEd("Not Ed") orelse false;
    std.debug.print("dude2 is {}\n", .{dude2});
    dudeIsEdOrError("Ed") catch unreachable;
    const dude3 = dudeIsEdishOrError("Not Ed") catch false;
    std.debug.print("dude3 is {}\n", .{dude3});
}
