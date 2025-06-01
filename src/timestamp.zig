const std = @import("std");

pub fn hasValidTimestamp(filename: []const u8) bool {
    if (filename.len < 17) return false;

    const pattern = "0000-00-00T000000";
    inline for (pattern, 0..) |c, i| {
        switch (c) {
            '0' => {
                if (!std.ascii.isDigit(filename[i])) return false;
            },
            else => {
                if (filename[i] != c) return false;
            },
        }
    }

    const year = std.fmt.parseInt(u16, filename[0..4], 10) catch return false;
    const month = std.fmt.parseInt(u8, filename[5..7], 10) catch return false;
    const day = std.fmt.parseInt(u8, filename[8..10], 10) catch return false;
    const hour = std.fmt.parseInt(u8, filename[11..13], 10) catch return false;
    const minute = std.fmt.parseInt(u8, filename[13..15], 10) catch return false;
    const second = std.fmt.parseInt(u8, filename[15..17], 10) catch return false;

    if (month < 1 or month > 12) return false;
    if (day < 1 or day > 31) return false;
    if (hour > 23) return false;
    if (minute > 59) return false;
    if (second > 59) return false;

    const days_in_month = switch (month) {
        2 => if (isLeapYear(year)) @as(u8, 29) else @as(u8, 28),
        4, 6, 9, 11 => 30,
        else => 31,
    };
    if (day > days_in_month) return false;

    return true;
}

fn isLeapYear(year: u16) bool {
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
}

test "hasValidTimestamp" {
    const testing = std.testing;

    try testing.expect(hasValidTimestamp("2024-01-16T020000_test.txt"));
    try testing.expect(hasValidTimestamp("2024-02-29T235959_leap.txt"));
    try testing.expect(hasValidTimestamp("2024-12-31T000000"));

    try testing.expect(!hasValidTimestamp("2024-13-01T000000_test.txt"));
    try testing.expect(!hasValidTimestamp("2024-04-31T000000_test.txt"));
    try testing.expect(!hasValidTimestamp("2023-02-29T000000_test.txt"));
    try testing.expect(!hasValidTimestamp("2024-01-16T240000_test.txt"));
    try testing.expect(!hasValidTimestamp("2024-01-16T006000_test.txt"));
    try testing.expect(!hasValidTimestamp("not_a_timestamp.txt"));
    try testing.expect(!hasValidTimestamp("2024-01-16_no_time.txt"));
    try testing.expect(!hasValidTimestamp("20240116T020000_test.txt"));
    try testing.expect(!hasValidTimestamp("2024-01-16-020000_test.txt"));
}
