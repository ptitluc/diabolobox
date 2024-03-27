/*
This file is part of Diabolobox - a library to design 3D printable boxes.
Copyright (C) 2024  Luc Milland

Diabolobox is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3
of the License, or (at your option) any later version.

Diabolobox is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Diabolobox. If not, see <https://www.gnu.org/licenses/>
*/

use <utils/diabolo.scad>;
use <utils/rsquare.scad>;
use <utils/hexmap.scad>;

// ###########################################################################
//                      BOX DIMENSIONS AND PARAMETERS
//  just copy the following variables in your code to override values.
// ###########################################################################
width         = 19;    // length on X axis
depth         = 34;    // length on Y axis
height        = 11;    // length on Z axis
thickness     = 2.4;   // panel thickness
edge_offset   = 1.5;   // left/right panel offset for top and bottom edges
corner_radius = 1;     // rounded top and bottom angle. 0 to disable.
fit_clearance = 3;     // assembly tighteness
inner_dim     = true;  // are width, depth and height outer or inner lengths ?

//// display variables
/* [View] */
flat = false;  
show_lid = true;
show_left = true;
show_right = true;
show_back = true;
show_front = true;
show_bottom = true;
show_feet = true;
show_board = true;
explode_distance = 0.0; // [0:0.5:20]
/* [Color] */
red = 1;      // [0:0.01:1]
green = 0.75; // [0:0.01:1]
blue = 0.18;  // [0:0.01:1]
alpha = 1;    // [0:0.01:1]

module __customizer_limit__() {};

// ###########################################################################
//                              OTHER VARIABLES
//        some attempt to keep the core code but still readable
// ###########################################################################
$fn=64; // we want nice rounded shapes, don't we ?

// variable shortcuts
inner  = inner_dim; 
th     = thickness;
e_off  = edge_offset; 
cr     = corner_radius; 
fc     = fit_clearance; 

// calculated variables
off = th + e_off + fc/2; // outer to inner dimension offset
ow  = inner_dim == true ? width + 2 * off : width;  // outer width
iw  = inner_dim == true ? width : width - 2 * off;  // inner width
od  = inner_dim == true ? depth + 2 * off : depth;  // outer depth
id  = inner_dim == true ? depth : depth - 2 * off;  // inner depth
oh  = inner_dim == true ? height + 2 * th : height; // outer height
ih  = inner_dim == true ? height : height - 2 * th; // inner height
dh  = diabolo_height(th);
sw = th + fc;            // slide width
sh = diabolo_height(sw); // slide height
fc_comp = (dt_height(sw) - dt_height(th))/2; // compensate fit clearance


// ###########################################################################
//                              CORE MODULES                 
//   * db_panel : get a blank panel
//   * diabolize_bt : add rails and slide to a top or bottom panel
//   * diabolize_lr : add rails and slide to a left or right panel
//   * diabolize_fb : add rails and slide to a front or back panel
// ###########################################################################

// ***************************************************************************
//              db_panel("top_bottom"|"left_right"|"front_back")
// ***************************************************************************
// get a blank panel before applying a diabolize_xx module.
//
// remember that all dimensions apply to a flat panel :
//  * width or depth of box -> x axis 
//  * height of box -> y axis 
//  * panel thickness -> z axis
//
// Useful to apply transformations with simple coordinates.
// Example, to add a 2mm hole in the middle of the left panel and add the
// diabolobox joint system :
//
// diabolize_lr("left")
// difference() {
//   db_panel("left_right");
//   translate([od/2, ih/2, -0.01]) cylinder(d=2, h=th+0.02);
// }
// ***************************************************************************
module db_panel(panel) {
  if (panel == "top_bottom") {
    linear_extrude(th) rsquare([ow, od], cr, center=false);
  }
  else {
    // front/back or left/right panel
    size = panel == "front_back" ? [iw, ih] : [od, ih];   
    linear_extrude(th) square(size);
  }
}

// ***************************************************************************
//                 diabolize_bt(bottom=true|false)
// ***************************************************************************
// add the diabolobox joint system to a top or bottom panel.
//
// bottom got additionnal slides for back and front panels.
// top is a lid, so :
//   * slides are looser
//   * slides are shorter
//   * a lock bit is added
// ***************************************************************************
module diabolize_bt(bottom=true) {
              //     left/right slides positions
              //|    X     |     Y     |      Z       |
  l_slide_pos = [  e_off   ,  -0.01    , th - sh + 0.01];
  r_slide_pos = [ow - e_off, od + 0.01 , th - sh + 0.01];
  //                front/back slides positions
  //            |    Y      |     X       |         Z          |
  f_slide_pos = [-e_off - sw, e_off + sw/2, 2 * th/3 - fc + 0.01];
  b_slide_pos = [-od + e_off, e_off + sw/2, 2 * th/3 - fc + 0.01];

  slide_width = bottom == true ? sw : sw + 0.2;  // +0.2 clearance for lid
  difference() {
    children(0);
    lid_height_comp = bottom == true ? [0, 0, 0] : [0, 0, diabolo_height(0.2)];
    lid_side_comp = bottom == true ? [0, 0, 0] : [0.1, 0, 0];
    y_right_off = bottom == true ? [0, 0, 0] : [0, th, 0];
    l_pos = l_slide_pos - lid_height_comp - lid_side_comp;
    r_pos = r_slide_pos - lid_height_comp + lid_side_comp - y_right_off;
    length = bottom == true ? od : od - th;
    // left slide
    translate(l_pos)
      diabolo(slide_width, length + 0.02, "bottom");
    // right slide
    translate(r_pos)
      rotate([0, 0,180])
      diabolo(slide_width, length + 0.02, "bottom");
    // front and back slides
    if (bottom==true) {
      rotate([0, 0, -90])
	translate(f_slide_pos)
	cube([sw, iw + sw, th/3 + fc]);
      rotate([0, 0, -90])
	translate(b_slide_pos)
	cube([sw, iw + sw, th/3 + fc]);
    }
  }
  if (bottom==false) {
    // blocker bit in the lid
    blocker_off = od - e_off - 1.5 * sw;
    translate([e_off + sw + sw/10, blocker_off, th - sh])
      cylinder(d=sw/2, h=dh);
  }
}

// ***************************************************************************
//                     diabolize_lr("left"|"right")
// ***************************************************************************
// add the diabolobox joint system to a left or right panel.
//
// A right panel has a the blocker hole for the lid to snap in place.
// ***************************************************************************
module diabolize_lr(side) {
  translate([0, dh, 0])
    difference () {
      union() {
	children(0);
	stop = side == "left" ? th : 0;
	// top diabolo
	translate([0, ih , 0])
	  cube([od, fc_comp, th]);
	rotate([0, 0, -90])
	translate([-ih -dh - fc_comp, stop, 0])
	difference() {
	  diabolo(th, od - th, "left");
	  if (side == "right") {
	    blockhole_off = od - e_off - 1.5 * sw;
	    translate([-0.01, blockhole_off, + sw/11])
	      rotate([0, 90, 0])
	      cylinder(d=sw/2, h=dh);
	  }
	}
	// bottom diabolo
	rotate([0, 0, -90])
	  translate([fc_comp, 0, 0])
	  diabolo(th, od, "right");
	translate([0, -fc_comp, 0])
	  cube([od, fc_comp, th]);
      }
      // back slide
      rotate([0, 90, 0])
	translate([-sh + 0.01, -dh - 0.01 - fc_comp, e_off])
	diabolo(sw, ih + 2*(fc_comp + dh) + 0.02, "left");
      // front slide
      rotate([0, 90, 0])
	translate([-sh + 0.01, -dh - 0.01 - fc_comp, od - sw - e_off])
	diabolo(sw, ih + 2*(fc_comp + dh) + 0.02, "left");
    }
}
// ***************************************************************************
//                     diabolize_fb()
// ***************************************************************************
// add the diabolobox joint system to a front or back panel.
//
// both are strictly the same
// ***************************************************************************
module diabolize_fb() {   
    height = ih + th/3;
    translate([dh, 0, 0]) cube([iw, th/3, th]);
    translate([dh, th/3, 0]) children(0);
    translate([-fc_comp, 0, 0]) diabolo(th, height, "left");
    translate([dh - fc_comp, 0, 0]) cube([fc_comp, height, th]);
    translate([iw + dh, 0, 0])  cube([fc_comp, height, th]);
    translate([iw + dh + fc_comp, 0, 0]) diabolo(th, height, "right");
}

// ###########################################################################
//                              OPTIONS
// commonly used add-ons like :
//   * feets
//   * vents
//   * internal pillars for electronic cards (pcb)
// ###########################################################################

// ***************************************************************************
//                      foot() and feet_slots()
// ***************************************************************************
//  to add feet to your box, just difference feet_slots() from your bottom
//  panel and generate four feets with foot(). Example :
//
//  diabolize_bt()
//  difference() {
//    db_panel("top_bottom");
//    feet_slots();
//  }
//
// for(i=[0:3]) {translate([i*5, 0, ])  foot();}
//
// ***************************************************************************
module foot() {
  th_m = 1.2 * th - 0.25;
  rotate([180, 0, 0])
    translate([0, -th_m, -th_m - dt_height(th_m)])
    dove_tail(th_m, th_m);
  translate([0, 0, 0]) cube([th_m, th_m, th_m]);
}

module feet_slots() {
  // feet slots
  f_off = 1.2 * off;
  f_th = 1.2 * th;
  dth = dt_height(f_th);
  translate([f_off, 1.5 * f_th - 0.01, dth - 0.01])
    rotate([180, 0, 0])
    dove_tail(f_th, 1.5 * f_th);
  translate([ow - f_off - f_th, 1.5 * f_th - 0.01, dth - 0.01])
    rotate([180, 0, 0])
    dove_tail(f_th, 1.5 * f_th);
  translate([ow - f_off - f_th, od + 0.01, dth - 0.01])
    rotate([180, 0, 0])
    dove_tail(f_th, 1.5 * f_th);
  translate([f_off, od + 0.01, dth - 0.01])
    rotate([180, 0, 0])
    dove_tail(f_th, 1.5*f_th);
}

// ***************************************************************************
//                      vents() and hex_vents()
// ***************************************************************************
// ready to use vents patterns (lines and hexagonal tiles) for boxes which
// need it, like raspberry pi cases. 
// Just substract it from the top or bottom panel you want to add it to :
//
//  diabolize_bt()
//  difference() {
//    db_panel("top_bottom");
//    vents();
//  }
//
//  diabolize_bt(bottom=false)
//  difference() {
//    db_panel("top_bottom");
//    hex_vents();
//  }
// ***************************************************************************
module vents() {
  v_off = 2 * off + 1;
  union() {
    for(i=[0:v_off/3: iw - v_off]) {
      x= i + v_off;
      y= v_off;
      translate([x, y, -0.01])
        cube([1.5, od - 2 * v_off, th + 0.02]);
    }
  }
}

module hex_vents(padding=0) {
  v_off = off + padding;
  w = iw - padding * 2;
  d = id - padding * 2;
  translate([v_off, v_off, -0.1])
    hexmap(d=th*3, h=th+0.2, space=th/4, bbox=[w, d]);
}

// ***************************************************************************
//                            pillars()
// ***************************************************************************
// Adds pillars for your pcb.
//
// Set pillars parameters by overriding the following variables :
// 
// pillar_dia = 0;
// pillar_bore_dia = 0;
// pillar_height = 0;
// pillars_coords = [[0, 0]];
//
// pillars_coords expect a set of [x, y] coordinates.
// A pillar is generated at this point, for each set in the list.
//
// example :
//
// pillar_dia = 6;
// pillar_bore_dia = 2.7;
// pillar_height = 3;
// pillars_coords = [[3.5, 26.7], [52.5, 26.7], [52.5, 84.8], [3.5, 84.8]];

// diabolize_bt()
// union() {
//   db_panel("top_bottom");
//   pillars();
// }
// ***************************************************************************
pillar_dia = 0;
pillar_bore_dia = 0;
pillar_height = 0;
pillars_coords = [[0, 0]];
ph = pillar_height;

module pillar() {
  d1 = pillar_dia;
  d2 = pillar_bore_dia;
    difference() {
        cylinder(ph, d=d1);
        translate([0,0,-0.1])
        cylinder(ph+0.2, d=d2);
    }
}

module pillars() {
  coords = pillars_coords;
  for(coord=coords) {
    translate([coord.x + off, coord.y + off, th]) pillar();
  }
}


// ###########################################################################
//                              ARRANGEMENT
//
// this is the presentation module of diabolobox, its usage is mandatory.
// You want it to be the module surrounding all your box definition.
//
// It allows displaying the box panels in two modes :
//  * flat, as in 3D printing ready
//  * assembled, as in 3D assembled view. 
// 
// To toggle between the modes, just use th `flat` variable.
// In assembled mode, you can use the explode_distance variable to control
// an exploded view of the box.
// Last but not least, you can toggle the display of each panel and optional
// feet by passing a vector of booleans to the arrange() module.
// ###########################################################################

// ***************************************************************************
//                            arrange(panels)
//
// important: the modules assume children (i.e. panels and feet) order is :
// left, bottom, right, top, front, back, feet
// panels can be toggle on/off with the `panels` parameter, which is a vector
// of booleans. Example :
//
// visible_panels = [true, true, true, false, false false, false];
// arrange(visible_panels) {
//   diabolize_lr("left") db_panel("left_right");
//   [ snip ... and all your other panels .. snip ]
// }
// 
// ***************************************************************************
module arrange(panels=[for (i=[0:6]) true]) {
  panel_h = ih + 2 * dh;
  space = 3;
  fb_panel_w = iw + 2 * dh;

  f_rotations    = [[0, 180, 90],
		    [0, 0, 0],
		    [0, 180, 90],
		    [0, 0, 0],
		    [0, 180, 0],
		    [0, 180, 0],
		    [0, 0, 0]];
  f_translations = [[-od, -panel_h, -th],
		    [panel_h + space, 0, 0],
		    [-od, - 2*space - 2 * panel_h - ow, -th],
		    [3 * space + 2 * panel_h + ow, 0],
		    [-fb_panel_w, od + space, -th],
		    [-2 * fb_panel_w - space, od + space, -th],
		    [2 * (fb_panel_w + space), od + space, 0]];
  a_rotations    = [[90, 0,-90],
		    [0, 0, 0],
		    [90, 0, 90],
		    [0, 180, 0],
		    [90, 0, 180],
		    [90, 0, 0],
		    [0, 0, 0]];
  a_translations = [[-od, th - dh, - off],
		    [0, 0, 0],
		    [0, th - dh, ow - off],
		    [-ow, 0, -oh],
		    [-ow + off - dh, 2 * th/3 - fc, od - off],
		    [off - dh, 2 * th/3 - fc, -off],
		    [20, -20, 0]];
  explode_dir    = [[0, 0, 1],
		   [0, 0, 0],
		   [0, 0, 1],
		   [0, 0, -1],
		   [0, 0, 1],
		   [0, 0, 1],
		   [0, 0, 0]];
  
  translations = flat == true ? f_translations : a_translations;
  rotations = flat == true ? f_rotations :  a_rotations;
  
  for (i=[0:1:$children-1]) {
    if (panels[i] == true) {
      explode_off = flat == true ? [0, 0, 0] : explode_distance * explode_dir[i];
      rotate(rotations[i])
	translate(translations[i] + explode_off)
	color([red, green, blue, alpha])
	children(i);
    }
  }
}
