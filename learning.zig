const std = @import("std");

pub fn main() void {
    const user = @import("models/user.zig").User{
        .name = "Goku",
        .power = 9001,
    };

    std.debug.print("{s}'s power is {d}\n", .{ user.name, user.power });
    std.debug.print("{any}\n", .{@TypeOf(.{ .year = 2023, .month = 8 })});
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
