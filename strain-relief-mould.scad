use <MCAD/array/rectangular.scad>
use <MCAD/array/translations.scad>
include <MCAD/units/metric.scad>

$fs = 0.4;
$fa = 1;

bbox_w = 40;
mold_size = [25, 25, 25];

function sq(x) = x * x;

module split_over_z (bbox = [1000, 1000, 1000])
{
    difference () {
        children ();

        translate ([0, 0, -bbox[2] / 2])
        cube (bbox, center = true);
    }

    translate ([bbox[0], 0, 0])
    rotate (180, X)
    difference () {
        children ();

        translate ([0, 0, bbox[2] / 2])
        cube (bbox, center = true);
    }
}

module mold_positive ()
{
    cube (mold_size, center = true);
}

module mold_alignment_pins ()
{
    for (x = [1, -1] * (mold_size[0] / 2 - 3)) {
        for (y = [1, -1] * (mold_size[1] / 2 - 3)) {
            translate ([x, y])
            cylinder (d = 3, h = 100, center = true);
        }
    }
}

module mold()
{
    rotate (180, X)
    split_over_z ([1, 1, 1] * bbox_w)
    difference () {
        mold_positive ();
        mold_alignment_pins ();
        children ();
    }
}

module fillet_shape (angle, radius)
{
	half_angle = 0.5 * angle;
	chord_corner_dist = radius * cos (half_angle) / tan (half_angle);
	chord_centre_dist = radius * sin (half_angle);

	corner_centre_dist = chord_centre_dist + chord_corner_dist;

	triangle_base = chord_corner_dist / cos(half_angle);

	difference () {
		polygon ([[0, 0], [triangle_base, 0], [triangle_base * cos (angle),
		                                       triangle_base * sin (angle)]]);

		translate ([corner_centre_dist * cos (half_angle),
		            corner_centre_dist * sin (half_angle)])
		circle (r = radius);
	}
}

module strain_relief_positive (smaller_d, bigger_d, fillet_r)
{
    joint_length = (bigger_d - smaller_d) / 2 * 2;
    joint_angle = 180 - atan2 (1, 2);

    mirror (Z)
    cylinder (d = smaller_d, h = 15);

    translate ([0, 0, -epsilon])
    cylinder (d = bigger_d, h = 15);

    step_dist = (bigger_d - smaller_d) / 2;
    translate ([0, 0, fillet_r - sqrt (sq (fillet_r) - sq (step_dist + epsilon * 3 - fillet_r))])
    intersection () {
        mirror (Z)
        rotate_extrude ()
        mirror (Z)
        translate ([smaller_d / 2 - epsilon * 2, 0])
        fillet_shape (90, fillet_r);

        cylinder (d = bigger_d, h = 1000, center = true);
    }
}

mold ()
rotate (90, Y)
strain_relief_positive (3.5, 5, 8);
