beltRollerDiameter = 50;
beltWidth = 13;
beltPlay = 2;
printPlay = 0.3;
beltRollerAxleDiameter = 10;
bearingDiameter = 16;
wallWhickness = 2;
rollerWallDistance = 1;

m10HexNutRadiusAcrossCorders = 18.48;
m10HexNutHeadHeight = 6.63;

ballBearingHeight=7;
ballBearingDiameter=22;

beltHeight = 1; // How thick the belt is
beltLayers = 15; // Amount of layers if the belt is rolled up, could be computed

beltRollerWidth = beltWidth + beltPlay; 

$fn=24;
module beltRoller() {
    outerBearingHeight = (wallWhickness + rollerWallDistance);
    difference() {
        union() {
            // Main body
            cylinder(r=beltRollerDiameter/2, h=beltRollerWidth);
            // Bearing
            translate([0, 0, -outerBearingHeight]) cylinder(r=bearingDiameter/2-printPlay, h=outerBearingHeight);
        }
        
        // Axle
        translate([0, 0, -50]) cylinder(r=beltRollerAxleDiameter/2+2*printPlay, h=100);
        // Hex Nut rotation coupler
        translate([0, 0, beltRollerWidth-m10HexNutHeadHeight-printPlay]) cylinder(r=m10HexNutRadiusAcrossCorders/2+printPlay, h=20, $fn=6);
        // Belt screw to fixate the belt at the roll, maybe a m3?
        translate([0, -10, 0.5*beltRollerWidth]) rotate([90, 0, 0]) cylinder(r=3/2+printPlay, h=beltRollerDiameter/2);
    }
}

function cornerPoints(d) = [
    [d, d*1.5, 0],
    [-d, d*1.5, 0],
    [d*1.5, -d, 0],
    [-d*1.5, -d, 0]
];

function caseScrewPoints(d) = cornerPoints(d-1);

module caseCorners(d, height, play=0) {
    cornerDiameter = 10;
    
    for ( p = cornerPoints(d) ){
        translate(p) cylinder(r=cornerDiameter/2+play, h=height);
    }
}

module caseBody(d, innerHeight) {
    caseWallThickness = 7;
    caseHeight = caseWallThickness + innerHeight;

    caseCorners(d-1, caseHeight);
    difference() {
        hull() { caseCorners(d, caseHeight); }
        translate([0, 0, caseWallThickness]) hull() { caseCorners(d-wallWhickness, caseHeight); }
    }
}

module bearingPlate() {
    // Bearing inset, used to have a tight fit with the roller without too much friction
    difference() {
        cylinder(r=beltRollerDiameter/2-3, height=rollerWallDistance-printPlay);
        translate([0, 0, -0.01]) cylinder(r=beltRollerDiameter/2-3-wallWhickness, h=rollerWallDistance+0.02);
    }
}

module caseLid(d) {
    height = wallWhickness;
    lidRegisterEdgeScaleFactor = (d-wallWhickness-printPlay) / d;
    
    module lidRegister() {
        difference() {
            scale([lidRegisterEdgeScaleFactor, lidRegisterEdgeScaleFactor, 1]) hull() caseCorners(d, rollerWallDistance);
            translate([0, 0, -0.01]) caseCorners(d-rollerWallDistance, height, 2*printPlay);
        }
    }

    translate([0, -0.25*d, 0]) difference() {
        union() {
            hull() caseCorners(d, height);

            // Registers against case body
            translate([0, 0, -rollerWallDistance]) difference() {
                lidRegister();
                translate([0, 0, -0.01]) scale([lidRegisterEdgeScaleFactor, lidRegisterEdgeScaleFactor, 1.1]) lidRegister();
            }

        }
        caseScrewHoles(d);
    }
    
    rotate([180, 0, 0]) bearingPlate();
}

module caseScrewHoles(d) {
    translate([0, 0, -5]) for ( p = caseScrewPoints(d) ){
        translate(p) cylinder(r=2+printPlay, h=50);
    }
}

module case(d) {
    height = beltRollerWidth+2*rollerWallDistance;

    difference() {
        translate([0, -0.25*d, 0]) difference() {
            caseBody(d, height);
            caseScrewHoles(d);
            // Case screw hex nuts
            translate([0, 0, -0.01]) for (p = caseScrewPoints(d)) {
                translate(p) cylinder(r=8.0/2+printPlay, h=3.2+2*printPlay, $fn=6);
            }
        }
        
        // Whole for the roll bearing to exit the case
        // translate([0, 0, 3.01]) color("lightgrey") beltRoller();
        translate([0, 0, -0.01]) color("grey") cylinder(r=ballBearingDiameter/2+printPlay, h=ballBearingHeight+0.02);

        
        // Hole for belt exiting the case
        translate([-2*d, -d, 7]) rotate([0, 0, 10]) cube([30, beltHeight*5, height-wallWhickness+0.1]);
    }
    
    // Ballbearing 
    color("grey") translate([0, 0, -4]) difference() {
        union() {
            cylinder(r1=7, r2=ballBearingDiameter/2+wallWhickness, h=4);
            translate([0, 0, -0.01]) color("grey") cylinder(r=12/2, h=4);
        }
        translate([0, 0, -0.02]) cylinder(r1=7, r2=ballBearingDiameter/2+wallWhickness, h=24);
    }
    
    translate([0, 0, 7-0.01]) bearingPlate();
}

d = beltRollerDiameter/2 + beltLayers * beltHeight;
case(d);
// translate([0, 0, 80]) caseLid(d);
