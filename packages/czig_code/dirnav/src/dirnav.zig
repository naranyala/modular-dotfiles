// src/main.zig - Fixed for Zig 0.14+ / 0.15+
const std = @import("std");
const process = std.process;
const fs = std.fs;
const mem = std.mem;
const ascii = std.ascii;

const MAX_PATHS = 100;
const MAX_PATH_LEN = 260;

const DirStore = struct {
    paths: [][]u8,
    allocator: std.mem.Allocator,
    count: usize,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .paths = allocator.alloc([]u8, MAX_PATHS) catch unreachable,
            .allocator = allocator,
            .count = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        for (self.paths[0..self.count]) |path| {
            self.allocator.free(path);
        }
        self.allocator.free(self.paths);
    }

    pub fn load(self: *Self) !void {
        const store_file = try getStoreFile(self.allocator);
        defer self.allocator.free(store_file);

        const file = fs.openFileAbsolute(store_file, .{}) catch |err| switch (err) {
            error.FileNotFound => return,
            else => return err,
        };
        defer file.close();

        const content = try file.readToEndAlloc(self.allocator, 1024 * 1024);
        defer self.allocator.free(content);

        var lines = std.mem.tokenizeAny(u8, content, "\n\r");
        var i: usize = 0;
        while (lines.next()) |line| : (i += 1) {
            if (i >= MAX_PATHS) break;
            if (line.len == 0) continue;

            self.paths[i] = try self.allocator.dupe(u8, line);
            self.count += 1;
        }
    }

    pub fn save(self: *Self) !void {
        const store_file = try getStoreFile(self.allocator);
        defer self.allocator.free(store_file);

        // Create directory if it doesn't exist
        if (std.fs.path.dirname(store_file)) |dir| {
            std.fs.cwd().makePath(dir) catch |err| switch (err) {
                error.PathAlreadyExists => {},
                else => return err,
            };
        }

        const file = try fs.createFileAbsolute(store_file, .{});
        defer file.close();

        // Zig 0.15.x: New I/O API requires explicit buffer
        var buffer: [4096]u8 = undefined;
        var file_writer = file.writer(&buffer);
        const writer = &file_writer.interface;

        for (self.paths[0..self.count]) |path| {
            try writer.print("{s}\n", .{path});
        }

        try writer.flush();
    }

pub fn addPath(self: *Self, path: []const u8) !void {
    if (self.count >= MAX_PATHS) {
        return error.StoreFull;
    }

    // Just duplicate the input path as-is (or normalize slashes if you want consistency)
    const stored_path = try normalizePath(self.allocator, path);
    errdefer self.allocator.free(stored_path);

    // Optional: prevent exact duplicates
    for (self.paths[0..self.count]) |existing| {
        if (mem.eql(u8, existing, stored_path)) {
            std.debug.print("ℹ️  Path already exists in store: {s}\n", .{stored_path});
            self.allocator.free(stored_path);
            return;
        }
    }

    // Store it — no filesystem access at all
    self.paths[self.count] = stored_path;
    self.count += 1;

    // Save to disk
    try self.save();

    std.debug.print("✅ Path added: {s}\n", .{stored_path});
}

    pub fn listPaths(self: *Self) void {
        if (self.count == 0) {
            std.debug.print("No paths stored yet.\n", .{});
            return;
        }

        std.debug.print("📂 Stored paths:\n", .{});
        for (self.paths[0..self.count], 0..) |path, i| {
            std.debug.print("[{d}] {s}\n", .{ i, path });
        }
    }

    pub fn removePath(self: *Self, index: usize) !void {
        if (index >= self.count) {
            return error.InvalidIndex;
        }

        const removed = self.paths[index];
        std.debug.print("🗑️ Removing: {s}\n", .{removed});

        // Shift remaining paths
        for (self.paths[index..self.count - 1], 0..) |*dest, i| {
            dest.* = self.paths[index + i + 1];
        }

        self.allocator.free(removed);
        self.count -= 1;
        try self.save();
    }

    pub fn navigate(self: *Self, index: usize) !void {
        if (index >= self.count) {
            return error.InvalidIndex;
        }

        std.debug.print("{s}\n", .{self.paths[index]});
    }

    pub fn searchPaths(self: *Self, keyword: []const u8) void {
        var found = false;

        // Allocate buffer for lowercase keyword
        const keyword_lower = self.allocator.alloc(u8, keyword.len) catch return;
        defer self.allocator.free(keyword_lower);

        // Convert keyword to lowercase
        for (keyword, 0..) |c, i| {
            keyword_lower[i] = ascii.toLower(c);
        }

        for (self.paths[0..self.count], 0..) |path, i| {
            // Allocate buffer for lowercase path
            const path_lower = self.allocator.alloc(u8, path.len) catch continue;
            defer self.allocator.free(path_lower);

            // Convert path to lowercase
            for (path, 0..) |c, j| {
                path_lower[j] = ascii.toLower(c);
            }

            if (mem.indexOf(u8, path_lower, keyword_lower) != null) {
                std.debug.print("[{d}] {s}\n", .{ i, path });
                found = true;
            }
        }

        if (!found) {
            std.debug.print("🔍 No match found for '{s}'\n", .{keyword});
        }
    }
};

fn normalizePath(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const normalized = try allocator.dupe(u8, path);
    errdefer allocator.free(normalized);

    if (builtin.os.tag == .windows) {
        // Windows: convert forward slashes to backslashes
        for (normalized) |*char| {
            if (char.* == '/') char.* = '\\';
        }
    } else {
        // Unix: convert backslashes to forward slashes
        for (normalized) |*char| {
            if (char.* == '\\') char.* = '/';
        }
    }

    return normalized;
}

const builtin = @import("builtin");

fn getHomeDir(allocator: std.mem.Allocator) ![]u8 {
    // Try environment variables in order
    const env_vars = [_][]const u8{ "DIRCLI_HOME", "HOME", "USERPROFILE" };

    for (env_vars) |env_var| {
        if (process.getEnvVarOwned(allocator, env_var)) |home| {
            return home;
        } else |_| {
            continue;
        }
    }

    // Fallback
    if (builtin.os.tag == .windows) {
        return allocator.dupe(u8, "C:\\");
    } else {
        return allocator.dupe(u8, "/tmp");
    }
}

fn getStoreFile(allocator: std.mem.Allocator) ![]u8 {
    if (process.getEnvVarOwned(allocator, "DIRCLI_STORE")) |custom| {
        return custom;
    } else |_| {
        const home = try getHomeDir(allocator);
        defer allocator.free(home);

        const store_file = try std.fs.path.join(allocator, &[_][]const u8{ home, ".dircli_store" });
        return store_file;
    }
}

const Error = error{
    StoreFull,
    InvalidIndex,
    EnvironmentVariableNotFound,
};

pub fn execute() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        printHelp();
        return;
    }

    var store = DirStore.init(allocator);
    defer store.deinit();

    try store.load();

    const command = args[1];

    if (mem.eql(u8, command, "--help")) {
        printHelp();
    } else if (mem.eql(u8, command, "--add")) {
        if (args.len < 3) {
            std.debug.print("❌ Missing path argument\n", .{});
            return;
        }
        try store.addPath(args[2]);
    } else if (mem.eql(u8, command, "--list")) {
        store.listPaths();
    } else if (mem.eql(u8, command, "--rm")) {
        if (args.len < 3) {
            std.debug.print("❌ Missing index argument\n", .{});
            return;
        }
        const index = try std.fmt.parseInt(usize, args[2], 10);
        try store.removePath(index);
    } else if (mem.eql(u8, command, "--nav")) {
        if (args.len < 3) {
            std.debug.print("❌ Missing index argument\n", .{});
            return;
        }
        const index = try std.fmt.parseInt(usize, args[2], 10);
        try store.navigate(index);
    } else if (mem.eql(u8, command, "--search")) {
        if (args.len < 3) {
            std.debug.print("❌ Missing keyword argument\n", .{});
            return;
        }
        store.searchPaths(args[2]);
    } else {
        std.debug.print("❌ Unknown command\n", .{});
        printHelp();
    }
}

fn printHelp() void {
    std.debug.print(
        \\Usage: dirnav [command] [options]
        \\Commands:
        \\  --add <path>       Add a directory path
        \\  --list             List stored paths
        \\  --rm <index>       Remove path at index
        \\  --nav <index>      Print path at index (use with cd)
        \\  --search <keyword> Search paths by keyword
        \\  --help             Show this help message
        \\
        \\Environment variables:
        \\  DIRCLI_STORE       Custom store file location
        \\
    , .{});
}

// pub fn main() !void {
//     try execute();
// }
