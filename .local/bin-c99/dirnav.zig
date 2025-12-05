const std = @import("std");
const fs = std.fs;
const io = std.io;
const mem = std.mem;
const process = std.process;

// Alias for a general-purpose allocator.
const Allocator = mem.Allocator;

// Constants matching the C code
const MAX_PATHS = 100;
const MAX_LEN = 4096; // Using a common PATH_MAX value, or you could use std.fs.MAX_PATH_BYTES

// Type alias for the list of stored directories.
// We store []const u8 (slices of bytes, which are Zig's strings)
// which will be owned by the ArrayList.
// NOTE: Using the internal ArrayType alias helps sometimes with type resolution.
const PathList = std.ArrayList([]const u8);

/// Resolve the store file location.
fn getStoreFile(allocator: Allocator) ![]const u8 {
    // 1. Check DIRCLI_STORE environment variable
    if (process.getEnvVarOwned(allocator, "DIRCLI_STORE")) |custom_path| {
        return custom_path;
    }

    // 2. Fallback to HOME/.dircli_store
    var home_path: ?[]const u8 = null;
    if (process.getEnvVarOwned(allocator, "HOME")) |h| {
        home_path = h;
    } else if (process.getEnvVarOwned(allocator, "USERPROFILE")) |h| { // Windows fallback
        home_path = h;
    }

    if (home_path) |h| {
        // FIX for ERROR 1: path_bytes is not mutated, so it should be 'const'.
        const path_bytes = try fs.path.join(allocator, &[_][]const u8{ h, ".dircli_store" });
        allocator.free(h); // Free the allocated env var string
        return path_bytes;
    } else {
        // If no HOME/USERPROFILE, use the current directory or handle error
        return error.HomePathNotFound;
    }
}

/// Loads paths from the store file.
fn loadPaths(allocator: Allocator) !PathList {
    // FIX for ERROR 2: Explicitly specifying the type upon initialization.
    // The original `var paths = PathList.init(allocator);` is technically correct
    // but the compiler was having trouble resolving the type context.
    var paths = PathList.init(allocator);

    const store_file = try getStoreFile(allocator);
    defer allocator.free(store_file);

    const file = fs.openFileAbsolute(store_file, .{}) catch |err| {
        // If the file doesn't exist, that's okay, return an empty list.
        if (err == error.FileNotFound) {
            return paths;
        }
        return err;
    };
    defer file.close();

    var reader = io.bufferedReader(file.reader());
    var buf: [MAX_LEN]u8 = undefined;

    while (paths.items.len < MAX_PATHS) {
        // Read a line from the file.
        const line = reader.readUntilDelimiterOrEof(&buf, '\n') catch |err| {
            if (err == error.EndOfStream) break;
            return err;
        };

        if (line.len == 0) break; // End of file

        // Copy the path string into the ArrayList's memory
        const path_slice = try allocator.dupe(u8, line);
        try paths.append(path_slice);
    }

    return paths;
}

/// Saves paths to the store file.
fn savePaths(paths: PathList) !void {
    const allocator = paths.allocator; // Get the allocator used by the PathList

    const store_file = try getStoreFile(allocator);
    defer allocator.free(store_file);

    // Open file for writing, truncating if it exists, creating if it doesn't.
    const file = fs.createFileAbsolute(store_file, .{.truncate = true}) catch |err| {
        std.log.err("Failed to save store: {s}", .{@errorName(err)});
        return err;
    };
    defer file.close();

    var writer = file.writer();

    for (paths.items) |path| {
        // Write path followed by a newline
        try writer.writeAll(path);
        try writer.writeAll("\n");
    }
}

/// Adds a path.
fn addPath(paths: *PathList, path_to_add: []const u8) !void {
    if (paths.items.len >= MAX_PATHS) {
        std.debug.print("❌ Store is full!\n", .{});
        return;
    }

    // Allocate and copy the path string
    const new_path = try paths.allocator.dupe(u8, path_to_add);
    errdefer paths.allocator.free(new_path);

    try paths.append(new_path);
    try savePaths(paths.*); // Save changes

    std.debug.print("✅ Path added: {s}\n", .{path_to_add});
}

/// Lists paths.
fn listPaths(paths: PathList) void {
    if (paths.items.len == 0) {
        std.debug.print("No paths stored yet.\n", .{});
        return;
    }
    std.debug.print("📂 Stored paths:\n", .{});
    for (paths.items, 0..) |path, i| {
        std.debug.print("[{d}] {s}\n", .{ i, path });
    }
}

/// Removes a path.
fn removePath(paths: *PathList, index: usize) !void {
    if (index >= paths.items.len) {
        std.debug.print("❌ Invalid index!\n", .{});
        return;
    }

    const removed_path = paths.items[index];
    std.debug.print("🗑️ Removing: {s}\n", .{removed_path});

    // Remove the path slice from the list and free the memory it used
    paths.allocator.free(paths.swapRemove(index));

    try savePaths(paths.*); // Save changes
}

/// Navigate (print path for shell to use).
fn navigate(paths: PathList, index: usize) void {
    if (index >= paths.items.len) {
        std.debug.print("❌ Invalid index!\n", .{});
        return;
    }

    // Print the path to stdout for the shell script to capture (e.g., `cd $(dircli --nav <index>)`)
    std.debug.print("{s}\n", .{paths.items[index]});
}

/// Search paths.
fn searchPaths(paths: PathList, keyword: []const u8) void {
    var found = false;
    for (paths.items, 0..) |path, i| {
        if (mem.indexOf(u8, path, keyword) != null) {
            std.debug.print("[{d}] {s}\n", .{ i, path });
            found = true;
        }
    }
    if (!found) {
        std.debug.print("🔍 No match found for '{s}'\n", .{keyword});
    }
}

/// Help message.
fn printHelp() void {
    std.debug.print("Usage: dircli [command] [options]\n", .{});
    std.debug.print("Commands:\n", .{});
    std.debug.print("  --add <path>       Add a directory path\n", .{});
    std.debug.print("  --list             List stored paths\n", .{});
    std.debug.print("  --rm <index>       Remove path at index\n", .{});
    std.debug.print("  --nav <index>      Print path at index (use with cd)\n", .{});
    std.debug.print("  --search <keyword> Search paths by keyword\n", .{});
    std.debug.print("  --help             Show this help message\n", .{});
}

/// Frees all memory owned by the PathList
fn cleanupPaths(paths: *PathList) void {
    for (paths.items) |path| {
        paths.allocator.free(path); // Free each path string
    }
    paths.deinit(); // Deallocate the ArrayList's internal buffer
}

pub fn main() !void {
    // Standard library uses the general-purpose allocator by default
    const allocator = std.heap.page_allocator;

    // Load paths. The PathList *owns* the memory for the path strings.
    var paths = try loadPaths(allocator);
    defer cleanupPaths(&paths); // Ensure memory is freed when main exits

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        printHelp();
        return;
    }

    // Arguments in Zig include the program name (args[0]), so actual command is args[1]
    const command = args[1];

    if (mem.eql(u8, command, "--help")) {
        printHelp();
    } else if (mem.eql(u8, command, "--add")) {
        if (args.len >= 3) {
            try addPath(&paths, args[2]);
        } else {
            std.debug.print("❌ Missing path for --add\n", .{});
            printHelp();
        }
    } else if (mem.eql(u8, command, "--list")) {
        listPaths(paths);
    } else if (mem.eql(u8, command, "--rm")) {
        if (args.len >= 3) {
            const index = std.fmt.parseInt(usize, args[2], 10) catch {
                std.debug.print("❌ Invalid index format\n", .{});
                return;
            };
            try removePath(&paths, index);
        } else {
            std.debug.print("❌ Missing index for --rm\n", .{});
            printHelp();
        }
    } else if (mem.eql(u8, command, "--nav")) {
        if (args.len >= 3) {
            const index = std.fmt.parseInt(usize, args[2], 10) catch {
                std.debug.print("❌ Invalid index format\n", .{});
                return;
            };
            navigate(paths, index);
        } else {
            std.debug.print("❌ Missing index for --nav\n", .{});
            printHelp();
        }
    } else if (mem.eql(u8, command, "--search")) {
        if (args.len >= 3) {
            searchPaths(paths, args[2]);
        } else {
            std.debug.print("❌ Missing keyword for --search\n", .{});
            printHelp();
        }
    } else {
        std.debug.print("❌ Unknown command\n", .{});
        printHelp();
    }
}

// Custom error for clarity
const Error = error{
    HomePathNotFound,
};
