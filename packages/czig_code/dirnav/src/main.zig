
// main.zig
const std = @import("std");
const dirnav = @import("./dirnav.zig");

pub fn main() !void {
    try dirnav.execute();
}
