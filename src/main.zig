const std = @import("std");

const zplotly = @import("zplotly");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    const data = [1]struct {
        z: [5][5]f64,
        type: []const u8,
    }{.{ .z = .{
        .{ 10, 10.625, 12.5, 15.625, 20 },
        .{ 5.625, 6.25, 8.125, 11.25, 15.625 },
        .{ 2.5, 3.125, 5.0, 8.125, 12.5 },
        .{ 0.625, 1.25, 3.125, 6.25, 10.625 },
        .{ 0, 0.625, 2.5, 5.625, 10 },
    }, .type = "contour" }};
    const layout = .{ .title = .{ .text = "Basic Contour Plot" } };
    try zplotly.plot(arena, io, "ZigPlotlyTest", data, layout);
}
