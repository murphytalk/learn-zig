const std = @import("std");

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
