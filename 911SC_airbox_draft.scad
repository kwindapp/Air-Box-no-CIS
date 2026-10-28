
// Porsche 911 SC EFI Airbox
// Reinforced perimeter mounting system
// V-shaped six-pipe arrangement
// Units: millimetres

$fn = 96;

// ============================================
// PARAMETERS
// ============================================

L = 300;
W = 140;
H = 85;

bottomL = 240;
wall = 4;

flangeT = 10;
lidT = 5;

portOD = 44;
portID = 36;
portLen = 35;

topBore = 63;

// ============================================
// LID SCREW SYSTEM
// ============================================

lidScrewD = 5.5;  // M5 clearance

bossD = 12;
bossDepth = 8;

// Preliminary insert dimensions.
// Adjust to actual insert specification.
insertPilotD = 6;
insertDepth = 8;

// Six screws along each long side
screwX = [-125,-75,-25,25,75,125];
screwY = [-61,61];

// ============================================
// THROTTLE FLANGE
// ============================================

throttleX = -92;
throttleY = 0;

throttlePlateSize = 110;
throttlePlateRadius = 15;
throttlePlateHeight = 8;

throttleHoleDiameter = 6.5;
throttleHoleOffset = 33;

// ============================================
// PIPE POSITIONS
// ============================================

pipeClearance = 7;

outerZ = -35;
middleZ = -64;

outerX = sqrt(
    pow(portOD + pipeClearance, 2) -
    pow(middleZ - outerZ, 2)
);

ports = [
    [-outerX, outerZ],
    [0, middleZ],
    [outerX, outerZ]
];

// Select "assembly", "body", or "lid"

part = "assembly";

// ============================================
// HELPERS
// ============================================

module rounded_rect(a,b,r) {
    hull() {
        for (x=[-a/2+r,a/2-r])
            for (y=[-b/2+r,b/2-r])
                translate([x,y])
                    circle(r=r);
    }
}

module tapered_body(a,b,c,d,zTop,zBottom) {
    hull() {
        translate([0,0,zTop])
            linear_extrude(0.1)
                rounded_rect(a,b,12);

        translate([0,0,zBottom])
            linear_extrude(0.1)
                rounded_rect(c,d,10);
    }
}

// ============================================
// LID SCREW POSITIONS
// ============================================

module lid_screw_positions() {
    for (x=screwX)
        for (y=screwY)
            translate([x,y,0])
                children();
}

// ============================================
// REINFORCEMENT BOSSES
// ============================================

module screw_bosses() {
    lid_screw_positions()
        translate([0,0,-flangeT-bossDepth])
            cylinder(
                d=bossD,
                h=flangeT+bossDepth
            );
}

// ============================================
// BODY INSERT PILOT HOLES
// ============================================

module body_screw_holes() {
    lid_screw_positions()
        translate([0,0,-insertDepth])
            cylinder(
                d=insertPilotD,
                h=insertDepth+0.1
            );
}

// ============================================
// LID SCREW CLEARANCE HOLES
// ============================================

module lid_screw_holes() {
    lid_screw_positions()
        translate([0,0,-1])
            cylinder(
                d=lidScrewD,
                h=lidT+2
            );
}

// ============================================
// SIDE PIPES
// ============================================

module tube_outer(side,x,z) {
    translate([x,side*(W/2-7),z])
        rotate([-side*90,0,0])
            cylinder(
                d=portOD,
                h=portLen+7
            );
}

module tube_bore(side,x,z) {
    translate([x,side*(W/2+portLen+2),z])
        rotate([side*90,0,0])
            cylinder(
                d=portID,
                h=portLen+35
            );
}

// ============================================
// MAIN AIRBOX SHELL
// ============================================

module airbox_shell() {
    difference() {
        union() {

            // Tapered main housing
            tapered_body(
                L,W,
                bottomL,W,
                -flangeT,-H
            );

            // Reinforced top flange
            translate([0,0,-flangeT])
                linear_extrude(flangeT)
                    rounded_rect(
                        L+16,W+16,13
                    );

            // Six intake pipes
            for (side=[-1,1])
                for (p=ports)
                    tube_outer(
                        side,
                        p[0],
                        p[1]
                    );
        }

        // Hollow cavity
        tapered_body(
            L-2*wall,
            W-2*wall,
            bottomL-2*wall,
            W-2*wall,
            2,
            -H+wall
        );

        // Open top
        translate([0,0,-flangeT])
            linear_extrude(flangeT+2)
                rounded_rect(
                    L-12,W-12,9
                );

        // Six continuous pipe bores
        for (side=[-1,1])
            for (p=ports)
                tube_bore(
                    side,
                    p[0],
                    p[1]
                );
    }
}

// ============================================
// COMPLETE REINFORCED BODY
// ============================================

module airbox_body() {
    difference() {
        union() {

            // Main hollow shell
            airbox_shell();

            // Reinforcement bosses
            screw_bosses();
        }

        // Blind pilot holes from top surface
        body_screw_holes();
    }
}

// ============================================
// THROTTLE FLANGE
// ============================================

module throttle_flange_plate() {
    translate([
        throttleX,
        throttleY,
        lidT
    ])
        linear_extrude(throttlePlateHeight)
            rounded_rect(
                throttlePlateSize,
                throttlePlateSize,
                throttlePlateRadius
            );
}

// ============================================
// THROTTLE MOUNTING HOLES
// ============================================

module throttle_mounting_holes() {
    for (x=[
        -throttleHoleOffset,
         throttleHoleOffset
    ])
        for (y=[
            -throttleHoleOffset,
             throttleHoleOffset
        ])
            translate([
                throttleX+x,
                throttleY+y,
                -1
            ])
                cylinder(
                    d=throttleHoleDiameter,
                    h=lidT+throttlePlateHeight+2
                );
}

// ============================================
// COMPLETE LID
// ============================================

module lid_complete() {
    difference() {
        union() {

            // Main lid plate
            linear_extrude(lidT)
                rounded_rect(
                    L+16,W+16,13
                );

            // Flat throttle flange
            throttle_flange_plate();
        }

        // 63 mm continuous throttle opening
        translate([
            throttleX,
            throttleY,
            -1
        ])
            cylinder(
                d=topBore,
                h=lidT+throttlePlateHeight+2
            );

        // Four throttle mounting holes
        throttle_mounting_holes();

        // Twelve lid mounting holes
        lid_screw_holes();
    }
}

// ============================================
// FINAL ASSEMBLY
// ============================================

if (part=="body" || part=="assembly")
    airbox_body();

if (part=="lid" || part=="assembly")
    lid_complete();
