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

a = 60; // dovetail angle
function dt_height(width) = width * tan(a)/4;
function dt_top_width(width) = 2*dt_height(width)/tan(a);
function diabolo_height(width) = dt_height(width)*1.5;
  
module dove_tail(width, depth) {
  x1 = width;
  h = dt_height(width);
  x2 = dt_top_width(width);
  
  translate([0, depth, 0])
  rotate([90, 0, 0]) 
  linear_extrude(depth)
  hull() {
    square([x1, 0.001]);
    translate([(x1-x2)/2, h]) square([x2, 0.001]);
  }      
}

module position(position, width) {
                          //           rotation     translation   
  transform = position == "left"   ? [[0, 90, 0],  [0, 0, width]] :
              position == "top"    ? [[0, 180, 0], [width, 0, diabolo_height(width)]] :
              position == "right"  ? [[0, -90, 0], [diabolo_height(width), 0, 0]] :
              position == "bottom" ? [[0, 0, 0],   [0, 0, 0]] : undef;
  assert(!is_undef(transform), str("position as to be 'left', 'top', 'right' or 'bottom'"));
  translate(transform[1]) rotate(transform[0]) children();
}

module __diabolo(width, depth) {
  dth = dt_height(width);
   translate([0, 0, dth/2]) {
     dove_tail(width, depth);
     translate([0, 0, dth]) mirror([0, 0, 1]) dove_tail(width, depth);
     translate([0, 0, -dth/2]) mirror([0, 0, 0]) cube([width, depth, dth/2]);
   }
}

module diabolo(width, depth, position) {
  position(position, width)  __diabolo(width, depth);
}

diabolo(7, 15, "bottom");
