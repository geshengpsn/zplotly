# zplotly

`zplotly` is a small Zig helper for rendering Plotly charts from Zig data.

It serializes Zig values to JSON, writes a standalone HTML file that loads Plotly from the CDN, and opens that file in the system browser.

## Requirements

- Zig `0.16.0` or newer
- Internet access when viewing charts, because the generated HTML loads Plotly from `https://cdn.plot.ly`
- A desktop opener command supported by your OS:
  - macOS: `open`
  - Linux: `xdg-open`
  - Windows: `cmd /C start`

## Run The Example

```sh
zig build run
```

The example in `src/main.zig` creates a basic contour plot and writes:

```text
ZigPlotlyTest.html
```

Then it opens the file in your default browser.

## Usage

Import the package module and call `zplotly.plot`:

```zig
const std = @import("std");
const zplotly = @import("zplotly");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    const data = .{
        .{
            .x = .{ 1, 2, 3, 4, 5 },
            .y = .{ 1, 4, 9, 16, 25 },
            .type = "scatter",
        },
    };

    const layout = .{
        .title = .{ .text = "Example Plot" },
    };

    try zplotly.plot(arena, io, "ExamplePlot", data, layout);
}
```

This creates `ExamplePlot.html` in the current working directory and opens it in the browser.

## API

```zig
pub fn plot(
    allocator: std.mem.Allocator,
    io: std.Io,
    title: []const u8,
    data: anytype,
    layout: anytype,
) !void
```

- `allocator`: allocator used to format the generated file name and HTML content
- `io`: Zig I/O interface used for file and process operations
- `title`: used as both the HTML `<title>` and output file name, with `.html` appended
- `data`: Zig value serialized into Plotly's `data` argument
- `layout`: Zig value serialized into Plotly's `layout` argument

## Test

```sh
zig build test
```

The tests currently verify file name generation, generated HTML content, and current-directory access.
