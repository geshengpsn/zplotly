//! By convention, root.zig is the root source file when making a package.
const std = @import("std");

const html =
    \\<!doctype html>
    \\<html>
    \\<head>
    \\    <meta charset="utf-8">
    \\    <title>{s}</title>
    \\    <script src="https://cdn.plot.ly/plotly-3.4.0.min.js" charset="utf-8"></script>
    \\    <style>
    \\        html, body, #tester {{ width: 100%; height: 100%; margin: 0; }}
    \\        body {{ font-family: system-ui, sans-serif; }}
    \\    </style>
    \\</head>
    \\<body>
    \\    <div id="tester"></div>
    \\    <script>
    \\        TESTER = document.getElementById('tester');
    \\        const data = JSON.parse('{f}');
    \\        const layout = JSON.parse('{f}');
    \\        Plotly.newPlot(TESTER, data, layout, {{ responsive: true }});
    \\    </script>
    \\</body>
    \\</html>
    \\
;

pub fn plot(allocator: std.mem.Allocator, io: std.Io, title: []const u8, data: anytype, layout: anytype) !void {
    const data_formatter = std.json.fmt(data, .{});
    const layout_formatter = std.json.fmt(layout, .{});
    const filename = try std.fmt.allocPrint(allocator, "{s}.html", .{title});
    defer allocator.free(filename);
    const content = try std.fmt.allocPrint(allocator, html, .{ title, data_formatter, layout_formatter });
    defer allocator.free(content);
    const cwd = std.Io.Dir.cwd();

    try cwd.writeFile(io, .{
        .sub_path = filename,
        .data = content,
    });

    // const html_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ cwd, filename });
    const argv = switch (@import("builtin").os.tag) {
        .macos => &.{ "open", filename },
        .linux => &.{ "xdg-open", filename },
        .windows => &.{ "cmd", "/C", "start", "", filename },
        else => return error.UnsupportedOs,
    };
    const result = try std.process.run(allocator, io, .{ .argv = argv });
    switch (result.term) {
        .exited => |code| if (code != 0) return error.OpenBrowserFailed,
        else => return error.OpenBrowserFailed,
    }
}

test "create file name" {
    const filename = try std.fmt.allocPrint(std.testing.allocator, "{s}.html", .{"test"});
    defer std.testing.allocator.free(filename);
    try std.testing.expectEqualStrings("test.html", filename);
}

test "create file content" {
    const data_formatter = std.json.fmt(.{ .x = 1 }, .{});
    const layout_formatter = std.json.fmt(.{ .y = 2 }, .{});
    const content = try std.fmt.allocPrint(std.testing.allocator, html, .{ "test", data_formatter, layout_formatter });
    defer std.testing.allocator.free(content);
    try std.testing.expectEqualStrings(
        \\<!doctype html>
        \\<html>
        \\<head>
        \\    <meta charset="utf-8">
        \\    <title>test</title>
        \\    <script src="https://cdn.plot.ly/plotly-3.4.0.min.js" charset="utf-8"></script>
        \\    <style>
        \\        html, body, #tester { width: 100%; height: 100%; margin: 0; }
        \\        body { font-family: system-ui, sans-serif; }
        \\    </style>
        \\</head>
        \\<body>
        \\    <div id="tester"></div>
        \\    <script>
        \\        TESTER = document.getElementById('tester');
        \\        const data = JSON.parse('{"x":1}');
        \\        const layout = JSON.parse('{"y":2}');
        \\        Plotly.newPlot(TESTER, data, layout, { responsive: true });
        \\    </script>
        \\</body>
        \\</html>
        \\
    , content);
}

test "open cwd dir" {
    const io = std.testing.io;
    const cwd = std.Io.Dir.cwd();
    try cwd.access(io, ".", .{
        .read = true,
    });
}
