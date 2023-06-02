const IRQL = @import("IRQL.zig");
const HAL = @import("hal");

pub const HCB = struct {
    hartID: i32 = 0,
    currentIRQL: IRQL.IRQLs = .IRQL_LOW,
    archData: HAL.Arch.ArchHCBData = HAL.Arch.ArchHCBData{},
    pendingSoftInts: u16 = 0,
    pendingSoftIntFirst: [8]?*const fn () callconv(.C) void = [8]?*const fn () callconv(.C) void{
        null,
        null,
        null, // TODO: Add User Dispatching
        null, // TODO: Add User Dispatching
        &IRQL.KDCSoftInt,
        &IRQL.KDCSoftInt,
        &IRQL.KDCSoftInt,
        &IRQL.KDCSoftInt,
    },
    kdcActive: bool = false,
    kdcHead: ?*IRQL.KDC = null,
    kdcTail: ?*IRQL.KDC = null,
};
