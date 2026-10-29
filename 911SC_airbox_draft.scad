
//
// PORSCHE 911 SC EFI AIRBOX - MODULAR PROTOTYPE
// All dimensions in mm. NOT production-verified.
//

$fn = 96;

// ==========================================
// SELECT PART FOR STL EXPORT
// ==========================================

// assembly
// body
// cover
// throttle_flange
// pipe_left_1 / 2 / 3
// pipe_right_1 / 2 / 3
// sensor_dummy

part = "assembly";

// ==========================================
// MAIN HOUSING
// ==========================================

L = 300;
W = 140;
H = 100;

bottomL = 240;
wall = 4;

flangeT = 10;
lidT = 5;

// ==========================================
// SIX INTAKE PIPES
// ==========================================

portOD = 44;
portID = 38;
portLen = 35;

pipeOverlap = 7;
pipeClearance = 7;

outerZ = -40;
middleZ = -70;

outerX = sqrt(
    pow(portOD + pipeClearance, 2)
    - pow(middleZ - outerZ, 2)
);

ports = [
    [-outerX, outerZ],
    [0, middleZ],
    [outerX, outerZ]
];

// ==========================================
// THROTTLE FLANGE
// ==========================================

throttleX = -92;
throttleY = 0;

topBore = 63;

throttlePlateSize = 110;
throttlePlateRadius = 15;
throttlePlateHeight = 8;

// Provisional mounting hole pattern
throttleHoleDiameter = 6.5;
throttleHoleOffsetX = 33;
throttleHoleOffsetY = 33;

// ==========================================
// THROTTLE O-RING
// ==========================================

// Groove dimensions are provisional

oringID = 67.5;
oringCord = 4;

oringCenterD = oringID + oringCord;

oringGrooveWidth = 4.3;
oringGrooveDepth = 3;

oringGrooveOuterD =
    oringCenterD + oringGrooveWidth;

oringGrooveInnerD =
    oringCenterD - oringGrooveWidth;

enableOringGroove = true;

// ==========================================
// BOSCH MAP SENSOR
// ==========================================

// Bosch 0 281 002 401
// VW/Audi 038 906 051 C
//
// Located on flat top cover.
// Dimensions must be checked on sensor.

enableMapSensor = true;

mapX = 55;
mapY = 0;
mapRotation = 0;

// Provisional mounting dimensions
mapHoleSpacing = 36;
mapScrewD = 4.5;
mapProbeD = 11.5;

// Hide dummy so holes remain visible
showSensorDummy = false;

// Visual placeholder dimensions
mapDummyLength = 48;
mapDummyWidth = 25;
mapDummyHeight = 12;

// ==========================================
// COVER SCREWS
// ==========================================

lidScrewD = 5.5;

bossD = 12;
bossDepth = 8;

insertPilotD = 6;
insertDepth = 8;

screwX = [-125,-75,-25,25,75,125];
screwY = [-61,61];

// ==========================================
// GEOMETRY HELPERS
// ==========================================

module rounded_rect(a,b,r) {
    hull()
        for(x=[-a/2+r,a/2-r])
            for(y=[-b/2+r,b/2-r])
                translate([x,y])
                    circle(r=r);
}

module tapered_body(
    a,b,c,d,zTop,zBottom
) {
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
// COVER SCREW POSITIONS
// ==========================================

module lid_screw_positions() {
    for(x=screwX)
        for(y=screwY)
            translate([x,y,0])
                children();
}

// ==========================================
// BODY SCREW BOSSES
// ==========================================

module screw_bosses() {
    lid_screw_positions()
        translate([
            0,0,
            -flangeT-bossDepth
        ])
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
                h=insertDepth+0.2
            );
}

// ==========================================
// COVER SCREW HOLES
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

// Pipes and openings use identical axes.

module pipe_axis(
    side,x,z,d,extra=0
) {
    translate([
        x,
        side*(W/2-pipeOverlap-extra),
        z
    ])
        rotate([-side*90,0,0])
            cylinder(
                d=d,
                h=portLen
                  +pipeOverlap
                  +2*extra
            );
}

// ==========================================
// INDIVIDUAL PIPE
// ==========================================

module individual_pipe(side,index) {
    p = ports[index];

    difference() {
        pipe_axis(
            side,p[0],p[1],portOD
        );

        pipe_axis(
            side,p[0],p[1],portID,1
        );
    }
}

// ==========================================
// PIPE OPENING IN HOUSING
// ==========================================

// Full outside-diameter opening.
// Final joint clearance not yet designed.

module body_pipe_opening(side,x,z) {
    pipe_axis(
        side,x,z,portOD,0.05
    );
}

// ==========================================
// AIRBOX SHELL
// ==========================================

module airbox_shell() {
    difference() {
        union() {

            // Tapered housing
            tapered_body(
                L,W,
                bottomL,W,
                -flangeT,-H
            );

            // Top mounting rail
            translate([0,0,-flangeT])
                linear_extrude(flangeT)
                    rounded_rect(
                        L+16,W+16,13
                    );
        }

        // Hollow interior
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

        // Six intake openings
        for(side=[-1,1])
            for(p=ports)
                body_pipe_opening(
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

        // Keep all pipe openings clear
        for(side=[-1,1])
            for(p=ports)
                body_pipe_opening(
                    side,p[0],p[1]
                );
    }
}

// ==========================================
// THROTTLE MOUNTING HOLES
// ==========================================

module throttle_mounting_holes() {
    for(x=[
        -throttleHoleOffsetX,
        throttleHoleOffsetX
    ])
        for(y=[
            -throttleHoleOffsetY,
            throttleHoleOffsetY
        ])
            translate([
                throttleX+x,
                throttleY+y,
                -1
            ])
                cylinder(
                    d=throttleHoleDiameter,
                    h=lidT
                      +throttlePlateHeight
                      +2
                );
}

// ==========================================
// THROTTLE O-RING GROOVE
// ==========================================

module throttle_oring_groove() {
    translate([
        throttleX,
        throttleY,
        lidT
          +throttlePlateHeight
          -oringGrooveDepth
    ])
        difference() {

            cylinder(
                d=oringGrooveOuterD,
                h=oringGrooveDepth+0.1
            );

            translate([0,0,-0.1])
                cylinder(
                    d=oringGrooveInnerD,
                    h=oringGrooveDepth+0.3
                );
        }
}

// ==========================================
// BOSCH MAP SENSOR CUTOUT
// ==========================================

// Three through holes:
// 1 centre probe opening
// 2 mounting screw holes

module map_sensor_cutout() {
    translate([mapX,mapY,0])
        rotate([0,0,mapRotation]) {

            // Sensor probe opening
            translate([0,0,-1])
                cylinder(
                    d=mapProbeD,
                    h=lidT+2
                );

            // Two mounting holes
            for(y=[
                -mapHoleSpacing/2,
                mapHoleSpacing/2
            ])
                translate([0,y,-1])
                    cylinder(
                        d=mapScrewD,
                        h=lidT+2
                    );
        }
}

// ==========================================
// OPTIONAL SENSOR DUMMY
// ==========================================

// Visual placeholder only.
// Not an accurate Bosch CAD model.

module map_sensor_dummy() {
    color("#30343b")
        translate([
            mapX,
            mapY,
            lidT+mapDummyHeight/2
        ])
            rotate([0,0,mapRotation])
                cube([
                    mapDummyWidth,
                    mapDummyLength,
                    mapDummyHeight
                ],center=true);
}

// ==========================================
// SEPARATE COVER
// ==========================================

module cover_plate() {
    difference() {

        linear_extrude(lidT)
            rounded_rect(
                L+16,W+16,13
            );

        // Throttle centre opening
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

        // Throttle mounting holes
        throttle_mounting_holes();

        // Bosch sensor cutouts
        if(enableMapSensor)
            map_sensor_cutout();
    }
}

// ==========================================
// SEPARATE THROTTLE FLANGE
// ==========================================

module throttle_flange() {
    difference() {

        // Main flange plate
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

        // Throttle centre bore
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

        // O-ring channel
        if(enableOringGroove)
            throttle_oring_groove();
    }
}

// ==========================================
// COMPLETE ASSEMBLY
// ==========================================

module full_assembly() {

    color("gold")
        airbox_body();

    color("orange")
        cover_plate();

    color("silver")
        throttle_flange();

    // Six separate pipes
    for(side=[-1,1])
        for(i=[0:2])
            color("gold")
                individual_pipe(side,i);

    // Optional sensor dummy
    if(enableMapSensor && showSensorDummy)
        map_sensor_dummy();
}

// ==========================================
// STL EXPORT SELECTOR
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

else if(part=="sensor_dummy")
    map_sensor_dummy();
