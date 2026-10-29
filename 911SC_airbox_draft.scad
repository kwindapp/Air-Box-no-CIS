
//
// PORSCHE 911 SC EFI AIRBOX
// MODULAR VERSION - SEPARATE STL EXPORT
//
// Units: mm
//

$fn = 96;

// ==========================================
// SELECT COMPONENT
// ==========================================

// "assembly"
// "body"
// "cover"
// "throttle_flange"
// "pipe_left_1"
// "pipe_left_2"
// "pipe_left_3"
// "pipe_right_1"
// "pipe_right_2"
// "pipe_right_3"

part = "assembly";

// ==========================================
// DIMENSIONS
// ==========================================

L = 300;
W = 140;
H = 85;

bottomL = 240;
wall = 4;

flangeT = 10;
lidT = 5;

portOD = 44;   // Outside diameter
portID = 38;   // Inside diameter 911 SC 1978
portLen = 35;

topBore = 63;

// ==========================================
// LID SCREWS
// ==========================================

lidScrewD = 5.5;

bossD = 12;
bossDepth = 8;

insertPilotD = 6;
insertDepth = 8;

screwX = [-125,-75,-25,25,75,125];
screwY = [-61,61];

// ==========================================
// THROTTLE FLANGE
// ==========================================

throttleX = -92;
throttleY = 0;

throttlePlateSize = 110;
throttlePlateRadius = 15;
throttlePlateHeight = 8;

throttleHoleDiameter = 6.5;
throttleHoleOffset = 33;

// ==========================================
// PIPE POSITIONS
// ==========================================

pipeClearance = 7;

outerZ = -30;   // Was -35
middleZ = -60;  // Was -64

outerX = sqrt(
    pow(portOD + pipeClearance,2) -
    pow(middleZ - outerZ,2)
);

ports = [
    [-outerX,outerZ],
    [0,middleZ],
    [outerX,outerZ]
];

// ==========================================
// HELPERS
// ==========================================

module rounded_rect(a,b,r) {
    hull() {
        for(x=[-a/2+r,a/2-r])
            for(y=[-b/2+r,b/2-r])
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

// ==========================================
// SCREW POSITIONS
// ==========================================

module lid_screw_positions() {
    for(x=screwX)
        for(y=screwY)
            translate([x,y,0])
                children();
}

// ==========================================
// SCREW BOSSES
// ==========================================

module screw_bosses() {
    lid_screw_positions()
        translate([0,0,-flangeT-bossDepth])
            cylinder(
                d=bossD,
                h=flangeT+bossDepth
            );
}

// ==========================================
// BODY INSERT HOLES
// ==========================================

module body_screw_holes() {
    lid_screw_positions()
        translate([0,0,-insertDepth])
            cylinder(
                d=insertPilotD,
                h=insertDepth+0.1
            );
}

// ==========================================
// LID SCREW HOLES
// ==========================================

module lid_screw_holes() {
    lid_screw_positions()
        translate([0,0,-1])
            cylinder(
                d=lidScrewD,
                h=lidT+2
            );
}

// ==========================================
// PIPE GEOMETRY
// ==========================================

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

// ==========================================
// INDIVIDUAL PIPE
// ==========================================

module individual_pipe(side,index) {
    p = ports[index];

    difference() {
        tube_outer(side,p[0],p[1]);
        tube_bore(side,p[0],p[1]);
    }
}

// ==========================================
// MAIN BODY WITHOUT PIPES
// ==========================================

module airbox_shell() {
    difference() {
        union() {

            // Main tapered housing
            tapered_body(
                L,W,
                bottomL,W,
                -flangeT,-H
            );

            // Top flange
            translate([0,0,-flangeT])
                linear_extrude(flangeT)
                    rounded_rect(
                        L+16,W+16,13
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

        // Pipe openings
        for(side=[-1,1])
            for(p=ports)
                tube_bore(
                    side,p[0],p[1]
                );
    }
}

// ==========================================
// COMPLETE BODY
// ==========================================

module airbox_body() {
    difference() {
        union() {

            airbox_shell();

            screw_bosses();
        }

        body_screw_holes();

        // Keep pipe passages open
        for(side=[-1,1])
            for(p=ports)
                tube_bore(
                    side,p[0],p[1]
                );
    }
}

// ==========================================
// COVER
// ==========================================

module cover_plate() {
    difference() {

        linear_extrude(lidT)
            rounded_rect(
                L+16,W+16,13
            );

        // Main throttle opening
        translate([
            throttleX,
            throttleY,
            -1
        ])
            cylinder(
                d=topBore,
                h=lidT+2
            );

        // Cover mounting holes
        lid_screw_holes();

        // Four throttle holes
        throttle_mounting_holes();
    }
}

// ==========================================
// THROTTLE MOUNTING HOLES
// ==========================================

module throttle_mounting_holes() {
    for(x=[
        -throttleHoleOffset,
        throttleHoleOffset
    ])
        for(y=[
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

// ==========================================
// SEPARATE THROTTLE FLANGE
// ==========================================

module throttle_flange() {
    difference() {

        translate([
            throttleX,
            throttleY,
            lidT
        ])
            linear_extrude(
                throttlePlateHeight
            )
                rounded_rect(
                    throttlePlateSize,
                    throttlePlateSize,
                    throttlePlateRadius
                );

        // Main opening
        translate([
            throttleX,
            throttleY,
            lidT-1
        ])
            cylinder(
                d=topBore,
                h=throttlePlateHeight+2
            );

        // Four mounting holes
        throttle_mounting_holes();
    }
}

// ==========================================
// FULL ASSEMBLY
// ==========================================

module full_assembly() {

    airbox_body();

    cover_plate();

    throttle_flange();

    for(side=[-1,1])
        for(i=[0:2])
            individual_pipe(side,i);
}

// ==========================================
// EXPORT SELECTOR
// ==========================================

if(part=="assembly")
    full_assembly();

else if(part=="body")
    airbox_body();

else if(part=="cover")
    cover_plate();

else if(part=="throttle_flange")
    throttle_flange();

else if(part=="pipe_left_1")
    individual_pipe(-1,0);

else if(part=="pipe_left_2")
    individual_pipe(-1,1);

else if(part=="pipe_left_3")
    individual_pipe(-1,2);

else if(part=="pipe_right_1")
    individual_pipe(1,0);

else if(part=="pipe_right_2")
    individual_pipe(1,1);

else if(part=="pipe_right_3")
    individual_pipe(1,2);
