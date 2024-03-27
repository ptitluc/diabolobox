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

include <diabolobox/diabolobox.scad>;

/* [Dimensions] */
width = 19;
depth = 34;
height = 11;
thickness = 2.4; // 0.1
edge_offset = 1.5;// 0.1
corner_radius = 1;// 0.1
fit_clearance = 0.30;// 0.05
inner_dim = true;

/* [View] */
flat = false;  
show_lid = true;
show_left = true;
show_right = true;
show_back = true;
show_front = true;
show_bottom = true;
show_feet = true;
explode_distance = 0.0; // [0:0.5:20]
/* [Color] */
red = 1; // [0:0.01:1]
green = 0.75; // [0:0.01:1]
blue = 0.3; // [0:0.01:1]
alpha = 0.95; // [0:0.01:1]

module __customizer_limit__() {};

visible_panels = [
     show_left, show_bottom, show_right,
     show_lid, show_back, show_front,
     show_feet];

arrange(visible_panels) {
  // left
  diabolize_lr("left") db_panel("left_right");
  // bottom
  diabolize_bt() difference() {
    db_panel("top_bottom");
    vents();
    feet_slots();
  }
  // right
  diabolize_lr("right") db_panel("left_right");
  // top
  diabolize_bt(bottom=false) difference() {
    db_panel("top_bottom");
    hex_vents(padding=2);
  }
  // back
  diabolize_fb() db_panel("front_back");
  // front
  diabolize_fb() db_panel("front_back");
  // Feet
  for(i=[0:3]) {translate([i*5, 0])  foot();}
};
