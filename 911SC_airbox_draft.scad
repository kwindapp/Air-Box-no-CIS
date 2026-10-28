
// Porsche 911 SC EFI Airbox
// V-shaped 6-pipe arrangement
// 7 mm clearance between adjacent pipes
// Units: millimetres

$fn = 96;

// ---------- PARAMETERS ----------

L = 300;
W = 140;
H = 85;

bottomL = 240;
wall = 4;

flangeT = 8;
lidT = 5;

portOD = 44;
portID = 36;
portLen = 35;

topBore = 63;

// ---------- PIPE POSITIONS ----------

// Pipe centres: X position, Z height
// Approx. 7 mm surface-to-surface clearance
// Middle pipe remains unchanged
// Same arrangement on both sides

outerX = sqrt(
    pow(portOD + 7, 2) -
    pow(64 - 35, 2)
);

ports = [
    [-outerX, -35],  // Left outer pipe
    [0,       -64],  // Middle pipe
    [outerX,  -35]   // Right outer pipe
];

part = "assembly";

// ---------- HELPERS ----------

module rounded_rect(a,b,r) {
    hull()
        for (x=[-a/2+r,a/2-r],
             y=[-b/2+r,b/2-r])
            translate([x,y])
                circle(r=r);
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

// ---------- MOUNTING HOLES ----------

module perimeter_holes() {
    for (x=[-138,-83,-28,27,82,137])
        for (y=[-70,70])
            translate([x,y,-10])
                cylinder(d=6.5,h=25);

    for (x=[-138,137])
        for (y=[-28,28])
            translate([x,y,-10])
                cylinder(d=6.5,h=25);
}

// ---------- TUBES ----------

module tube_outer(side,x,z) {
    translate([x,side*(W/2-7),z])
        rotate([-side*90,0,0])
            cylinder(d=portOD,h=portLen+7);
}

module tube_bore(side,x,z) {
    translate([x,side*(W/2+portLen+2),z])
        rotate([side*90,0,0])
            cylinder(d=portID,h=portLen+35);
}

// ---------- MAIN BODY ----------

module airbox_body() {
    difference() {
        union() {

            // Tapered housing
            tapered_body(
                L,W,
                bottomL,W,
                -flangeT,-H
            );

            // Top flange
            translate([0,0,-flangeT])
                linear_extrude(flangeT)
                    rounded_rect(L+16,W+16,13);

            // Six side tubes
            for (side=[-1,1])
                for (p=ports)
                    tube_outer(side,p[0],p[1]);
        }

        // Hollow internal cavity
        tapered_body(
            L-2*wall,W-2*wall,
            bottomL-2*wall,W-2*wall,
            2,-H+wall
        );

        // Open top
        translate([0,0,-flangeT])
            linear_extrude(flangeT+2)
                rounded_rect(L-12,W-12,9);

        // Six continuous tube bores
        for (side=[-1,1])
            for (p=ports)
                tube_bore(side,p[0],p[1]);

        perimeter_holes();
    }
}

// ---------- LID ----------

module lid_plate() {
    difference() {
        linear_extrude(lidT)
            rounded_rect(L+16,W+16,13);

        perimeter_holes();

        translate([-92,0,-1])
            cylinder(d=topBore,h=lidT+3);
    }
}

// ---------- THROTTLE FLANGE ----------

module throttle_flange() {
    difference() {
        union() {

            // Compact mounting plate
            translate([-92,0,lidT])
                linear_extrude(8)
                    rounded_rect(94,94,12);

            // Circular inlet boss
            translate([-92,0,lidT+8])
                cylinder(d=75,h=18);
        }

        // 63 mm continuous inlet
        translate([-92,0,lidT-1])
            cylinder(d=topBore,h=30);

        // Four mounting holes
        for (x=[-39,39])
            for (y=[-39,39])
                translate([-92+x,y,lidT-1])
                    cylinder(d=6.5,h=11);
    }
}

// ---------- ASSEMBLY ----------

if (part=="body" || part=="assembly")
    airbox_body();

if (part=="lid" || part=="assembly")
    union() {
        lid_plate();
        throttle_flange();
    }
