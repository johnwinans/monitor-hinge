/*
*    Hinge-parts for mounting a video monitor under a shelf.
*
*    Copyright (C) 2021 John Winans
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



// The following values are suitable for mounting the hinge under
// a shelf with drywall screws.

uni_span=41;    // unistrut cross-section
uni_width=40;   // the width of the mounting block
uni_height=30;  // the thickness of the mounting block
uni_detent_depth=1; // how deep to cut the detent slot to hold monitor rotated up

//uni_bolt_dia=10;    // suitable for 3/8" bolt (for unistrut)
uni_bolt_dia=5;     // suitable for a drywall screw

rod_hanger_dia=6.9; // suitable for 1/4" threaded rod
rod_hanger_inset=7; // distance from hanger rod to the edge of the block



// The following values are suitable for mounting a ZSCMALLS Portable 15.6 Inch monitor.
// $129.99 at Amazon on 2020/11  ASIN: B07VFF4TZG
// Remove the monitor from its cover & reuse the same bolts to attach the monitor brackets!

mb_rod_inset=5;
mb_width=360;       // outside width of monitor plus a small gap
mb_height=50;
mb_thick=rod_hanger_dia+2*mb_rod_inset;

mb_mount_bolt_dia=5;    // suitable for M4 bolt
mb_mount_bolt_span=268; // distance between mounting bolts
mb_mount_countersink_depth=mb_thick-3;
mb_mount_countersink_dia=13;
mb_mount_bolt_inset=10;






// Using these direct-calls are useful for debugging with the OpenSCAD GUI.
// Uncomment one of these to print one of the parts of the hinge.

//uniblock();           // left-side mounting block
//uniblock(left=false); // right-side mounting block

//mb_half();            // left-side monitor bracket
//mb_half(left=false);  // right-side monitor bracket
//monitorbracket();       // the whole monitor bracket






/**
* This section is so that you can use the same file to generate 
* each of four parts one at-a-time from a Makefile by defining
* 'make_this' to any of:
*
* 0 = do nothing (use the above function-calls to select what to print)
* 1 = left-side mounting block
* 2 = right-side mounting block
* 3 = left-side monitor mounting bracket
* 4 = right-side monitor mounting bracket
*
* Note that uni_bolt_dia is also able to be overridden from the
* command-line/Makefile.
*
* By default this code will do nothing.
******************************************************************/
make_this=4;				// by default, do nothing

if (make_this==1)
	uniblock();				// left-side mounting block
else if (make_this==2)
	uniblock(left=false);	// right-side mounting block
else if (make_this==3)
	mb_half();				// left-side monitor bracket
else if (make_this==4)
	mb_half(left=false);	// right-side monitor bracket



/**
* A block used to attach one end of the monitor to Unistrut.
******************************************************************/
module uniblock(left=true)
{
    rod_hanger_offset = -uni_height/2+rod_hanger_dia/2+rod_hanger_inset;
    groove_offset = left ? uni_width/2 : -uni_width/2;
    rot = left ? -90 : 90;
    
    rotate([0,rot,0])   // print with detent up so not need support
    difference()
    {
        cube([uni_width, uni_span, uni_height], center=true);
        // unistrut mounting bolt hole
        cylinder(d=uni_bolt_dia, h=uni_height+.01, center=true, $fn=30);
        
        // hanger bolt hole
        translate([0,-uni_span/2+rod_hanger_dia/2+rod_hanger_inset, rod_hanger_offset])        
            rotate([0,90,0]) cylinder(d=rod_hanger_dia, h=uni_width+.01, center=true, $fn=30);
        
        // a detent slot to help hold the monitor when pushed back/up
        translate([groove_offset, 0, rod_hanger_offset]) 
        {
            detent_dia=rod_hanger_dia;
            cube([uni_detent_depth, uni_span+.01, rod_hanger_dia], center=true);
            for (x=[uni_detent_depth/2,-uni_detent_depth/2])
            {
                translate([x,0,0]) 
                    rotate([90,0,0]) 
                    scale([.3,1,1]) 
                    cylinder(d=detent_dia, h=uni_span+.01, center=true, $fn=30);
            }
        }
    }
}

/**
******************************************************************/
module mb_half(left=true)
{
    mask_width=mb_width/2+5;    // extra to eat the tongue as well
    mask_offset=left?mask_width/2:-mask_width/2;
    
    rotate([90,0,0])    // render it ready to print
    difference()
    {
        monitorbracket();
        translate([mask_offset,0,0]) cube([mask_width+.01,mb_thick+.01,mb_height+.01], center=true);
    }
}

/**
******************************************************************/
module monitorbracket()
{
    bolt_length = mb_width+uni_detent_depth*2+3;
    
    difference()
    {
        union()
        {
            cube([mb_width, mb_thick, mb_height], center=true);

            // tongues to mate the groove in the uniblock
            for ( x = [mb_width/2, -mb_width/2] )
            {
                translate([x, 0, 0]) 
                {
                    for ( x=[uni_detent_depth/2, -uni_detent_depth/2])
                    translate([x,0,0]) scale([.3,1,1]) cylinder(d=rod_hanger_dia-1, h=mb_height, center=true, $fn=30);
                   cube([uni_detent_depth, rod_hanger_dia-1, mb_height], center=true);
                }
            }
        }
        
        // the holes for the threaded rod
        translate([0,0,mb_height/2-rod_hanger_dia/2-mb_rod_inset])
            rotate([0,90,0]) cylinder(d=rod_hanger_dia, h=bolt_length+.01, center=true, $fn=30);
    
        // the holes for the monitor mounting bolts
        for ( x = [-mb_mount_bolt_span/2, mb_mount_bolt_span/2 ])
            translate([x,0,-mb_height/2+mb_mount_countersink_dia/2+mb_mount_bolt_inset])
            {
                rotate([-90,0,0]) 
                {
                    // the mounting bolt hole
                    cylinder(d=mb_mount_bolt_dia, h=mb_thick+.01, center=true, $fn=30);
                    // the countersink bore
                    translate([0,0,mb_thick/2-mb_mount_countersink_depth/2])
                        cylinder(d=mb_mount_countersink_dia, h=mb_mount_countersink_depth+.01, center=true, $fn=30);
                }
            }
        
        for (x = [-mb_width/2+20, -20] )
        // slots for a cable-bundle zip-tie 
        translate([x,-mb_thick/2,-mb_height/2]) 
        {
            // slot on bottom
            cube([10,6,20], center=true);
            // slot on top
            translate([0,mb_thick,0]) cube([10,6,20], center=true);
            // slot through the bracket
            translate([0,mb_thick/2,10]) cube([10,mb_thick+.01,5], center=true);
        }
    }
}
