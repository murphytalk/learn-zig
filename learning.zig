const std = @import("std");

pub fn main() void {
    const user = @import("models/user.zig").User{
        .name = "Goku",
        .power = 9001,
    };

    std.debug.print("{s}'s power is {d}", .{ user.name, user.power });
}
