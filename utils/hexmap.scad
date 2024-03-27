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

d = 4;
r = d/2;
h = 5;
space = 0.5;
bbox = [30, 40];

x_step = d *cos(30);
odd_offset = r*cos(30);
y_step = d*0.75;
max_x = floor(bbox[0]/(x_step));
max_y = floor(bbox[1]/y_step);

module hexmap(d=4, h=5, space=0.5, bbox=[42, 42]) {
    r = d/2;
    x_step = d *cos(30);
    odd_offset = r*cos(30);
    y_step = d*0.75;
    max_x = floor(bbox[0]/(x_step));
    max_y = floor(bbox[1]/y_step);
    
    intersection() {
        translate([0, 0, +0.01]) linear_extrude(h - 0.02 ) square(bbox);  
        for (i=[0:1:max_x], j=[0:1:max_y]) {
            if (j % 2 == 0) {
                translate([i * x_step + odd_offset,j * y_step])
                        rotate([0, 0, 90])
                cylinder(h=h, r=r-space/2, $fn=6, center=false);
            } else {
                translate([i * x_step,j * y_step])
                        rotate([0, 0, 90])
                cylinder(h=h, r=r-space/2, $fn=6, center=false);
            }
        }
    }
}
hexmap();
