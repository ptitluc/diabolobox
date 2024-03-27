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

module rsquare(size, r, center=true) {
  if(r<=0) {square(size, center);}
  else {
      x = size[0] - 2*r;
      y = size[1] - 2*r;
      off = center == true ? [-x/2, -y/2] : [r, r];
      
      translate(off)
        hull() {
        circle(r);
        translate([x, 0]) circle(r);
        translate([x, y]) circle(r);
        translate([0, y]) circle(r);
      }
   }
}

$fn = 32;
rsquare([5, 5], 1, center=false);
