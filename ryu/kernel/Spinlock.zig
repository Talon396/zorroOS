const std = @import("std");
const builtin = @import("builtin");
const HAL = @import("root").HAL;

pub const Spinlock = enum(u8) {
    unaquired = 0,
    aquired = 1,

    pub fn acquire(spinlock: *volatile Spinlock) void {
        var cycles: usize = 0;
        while (cycles < 50000000) : (cycles += 1) {
            if (@cmpxchgWeak(Spinlock, spinlock, .unaquired, .aquired, .Acquire, .Monotonic) == null) {
                return;
            }
            std.atomic.spinLoopHint();
        }
        HAL.Crash.Crash(.RyuDeadlock, .{ @intFromPtr(spinlock), 0, 0, 0 });
    }

    pub inline fn release(spinlock: *volatile Spinlock) void {
        @atomicStore(Spinlock, spinlock, .unaquired, .Release);
    }
};
