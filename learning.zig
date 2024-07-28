const std = @import("std");
const mymodules = @import("models/user.zig");

pub fn main() void {
    const user = @import("models/user.zig").User{
        .name = "Goku",
        .power = 9001,
    };

    std.debug.print("{s}'s power is {d}\n", .{ user.name, user.power });
    std.debug.print("{any}\n", .{@TypeOf(.{ .year = 2023, .month = 8 })});

    for (0..10) |i| {
        std.debug.print("{d}\n", .{i});
    }
}

test "array" {
    const a = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expect(a.len == 5);
    try std.testing.expect(a[0] == 1);

    //won't compile
    //const a5 = a[5];
    //std.debug.print("{d}", .{a5});

    const b = a[1..4];
    //won't compile even using var for b, as a is a const
    //b[1] = 100;
    try std.testing.expect(b[0] == 2);
    try std.testing.expect(b.len == 3);
    std.debug.print("{any}", .{@TypeOf(b)});
}

test "slice" {
    const a = [_]i32{ 1, 2, 3, 4, 5 };
    var end: usize = 3;
    end += 1;
    const b = a[1..end];

    //can compile , as slice has len in run-time , but will crash
    //const b5 = b[5];
    //std.debug.print("{d}", .{b5});
    try std.testing.expect(b[0] == 2);
    try std.testing.expect(b.len == 3);
    std.debug.print("{any}", .{@TypeOf(b)});
}

test "mem leak" {
    var list = std.ArrayList(u21).init(std.testing.allocator);
    defer list.deinit();
    try list.append('s');
    try std.testing.expect(list.items.len == 1);
    return error.SkipZigTest;
}
//const TimestampType = enum {
//    unix,
//    datetime,
//};

//const Timestamp = union(TimestampType) {
const Timestamp = union(enum) {
    unix: i32,
    datetime: DateTime,

    const DateTime = struct {
        year: u16,
        month: u8,
        day: u8,
        hour: u8,
        minute: u8,
        second: u8,
    };

    fn seconds(self: Timestamp) u16 {
        switch (self) {
            .datetime => |dt| return dt.second,
            .unix => |ts| {
                const seconds_since_midnight: i32 = @rem(ts, 86400);
                return @intCast(@rem(seconds_since_midnight, 60));
            },
        }
    }
};

test "tagged union" {
    const ts = Timestamp{ .unix = 1693278411 };
    std.debug.print("{d}\n", .{ts.seconds()});
}

test "optional" {
    const v1: ?[]const u8 = null;
    const v2: ?[]const u8 = "leto\n";

    if (v1) |h| {
        std.testing.expect(false);
        std.debug.print("{s}", .{h});
    } else {
        std.debug.print("null {any}\n", .{@TypeOf(v1)});
    }
    if (v2) |h| {
        // need to use try otherwise will have error
        //  error: error union is ignored
        // because expect might return error and needs to be handled
        try std.testing.expect(true); //or just: catch unreachable;
        std.debug.print("{s}", .{h});
    } else {
        std.testing.expect(false);
    }

    const v = v1 orelse "unknown";
    try std.testing.expect(std.mem.eql(u8, v, "unknown"));
}

fn levelUp(user: *mymodules.User) void {
    user.power += 1;
}

test "pointer" {
    var user = mymodules.User{
        .name = "Goku",
        .power = 9001,
    };

    levelUp(&user);
    try std.testing.expect(user.power == 9002);
}

var userPtr: u64 = 0;
fn creatUser(allocator: std.mem.Allocator, power: u64) !*mymodules.User {
    const user = try allocator.create(mymodules.User);
    userPtr = @intFromPtr(user);
    user.* = .{ .power = power, .name = "abc" };
    return user;
}

test "allocator" {
    const power = 123456;
    const alloc = std.testing.allocator;
    const u: *mymodules.User = try creatUser(alloc, power);
    defer alloc.destroy(u);
    try std.testing.expect(power == u.power);
    const p: u64 = @intFromPtr(u);
    std.debug.print("userPtr={d} p={d}\n", .{ userPtr, p });
    try std.testing.expect(userPtr == p);

    const s = try std.fmt.allocPrint(alloc, "user power={d}", .{u.power});
    defer alloc.free(s);

    try std.testing.expect(std.mem.eql(u8, s, "user power=123456"));
}

// https://www.openmymind.net/Zig-Interfaces/
const MyIF = struct {
    ptr: *anyopaque,
    func: *const fn (ptr: *anyopaque, data: i8, msg: []const u8) anyerror!i8,

    fn func(self: MyIF, data: i8, msg: []const u8) !i8 {
        return self.func(self.ptr, data, msg);
    }
};

const TestIF = struct {
    name: []const u8,
    fn func(ptr: *anyopaque, data: i8, msg: []const u8) !i8 {
        const self: *TestIF = @ptrCast(@alignCast(ptr));
        std.debug.print("{s} says {s}\n", .{ self.name, msg });
        return data * 2;
    }

    fn myif(self: *TestIF) MyIF {
        return .{ .ptr = self, .func = func };
    }
};

fn run_MyIF(i: MyIF, data: i8, msg: []const u8) !i8 {
    return MyIF.func(i, data, msg);
}

test "interface" {
    var i = TestIF{ .name = "Test IF" };
    const data: i8 = 15;
    const mi = TestIF.myif(&i);
    try std.testing.expect((2 * data) == try run_MyIF(mi, data, "My IF"));
}
