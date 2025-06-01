const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create an executable file
    const exe = b.addExecutable(.{
        .name = "ce",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the executable
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // Handle input arguments
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Add a step to run the application
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Configure unit tests
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    
    // Add a clean step to remove unnecessary build files (optional)
    const clean_step = b.step("clean", "Clean build artifacts");
    clean_step.dependOn(b.getInstallStep());
}
