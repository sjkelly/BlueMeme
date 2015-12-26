include <Magpie/magpie.scad>; // https://github.com/sjkelly/Magpie/blob/master/docs/tutorial.md
include <config.scad>;

// Index aliases for those in 1-indexed land
X = 0;
Y = 1;
Z = 2;
E = 3;

/*
TODO
        BLOCK, THEN POLISH

- plate
- feet
- z mount
- x-z mount
- x mount
- y-z carriage
- y car

*/

module plate(steppers, plate_dims){
    x_step = object(steppers[X]);
    z_step = object(steppers[Z]);
    cutout_dims = [plate_dims[X]-z_step[WIDTH]-x_step[WIDTH],
                   plate_dims[Y]+2,
                   plate_dims[Z]-z_step[WIDTH]-x_step[WIDTH]];
    color("tan")
    difference(){
        translate([0,-plate_dims[Y]/2,0])cube(plate_dims);
        //cutout
        translate([z_step[WIDTH],-plate_dims[Y]/2-1,z_step[WIDTH]])
            cube(cutout_dims);
        // Z motor
        translate([z_step[WIDTH]/2,
                   -z_step[LENGTH]-plate_dims[Y]/2,
                   z_step[WIDTH]/2])
            rotate([-90,0,0])
                stepper(steppers[Z],diff=true,diff_length=plate_thickness*2);
        // X motor
        translate([-x_step[WIDTH]/2+plate_dims[X],
                   x_step[LENGTH]+plate_thickness/2,
                   -x_step[WIDTH]/2+plate_dims[Z]])
            rotate([90,0,0])
                stepper(steppers[X],diff=true,diff_length=plate_thickness*2);
    }
}

module rod_end(stepper, rod_dia, spacing,plate_thickness){
    stepper_obj = object(stepper);
    x_max = rod_dia*2;
    z_max = stepper_obj[WIDTH];
    y_max = spacing+rod_dia*2;
    translate([-x_max,-y_max/2,0])difference(){
        union(){
            cube([x_max,y_max,z_max]);
            // TODO this has a constant
            translate([x_max,y_max/2+plate_thickness/2,0])
                cube([stepper_obj[WIDTH],5,stepper_obj[WIDTH]]);
        }
        translate([x_max/2,rod_dia,-1])union(){
            polyCylinder(r=rod_dia/2, h = z_max+2);
            translate([0,spacing,0])polyCylinder(r=rod_dia/2, h = z_max+2);
        }
        translate([stepper_obj[WIDTH]/2+x_max,
                   -y_max/2,
                   stepper_obj[WIDTH]/2])
            rotate([-90,0,0])
                stepper(stepper, diff=true,diff_length=50);
    }
}

module assembly(build_volume, rod_dia, steppers, plate_thickness, rod_spacing){
    // Stepper objects
    x_step = object(steppers[Z]);
    z_step = object(steppers[Z]);

    xz_stepper_width = x_step[WIDTH]+z_step[WIDTH];

    plate_dims = [build_volume[X]+xz_stepper_width,
                        plate_thickness,
                        build_volume[Z]+xz_stepper_width];
    plate(steppers,plate_dims);
    // Z motor
    translate([z_step[WIDTH]/2,
               -z_step[LENGTH]-plate_thickness/2,
               z_step[WIDTH]/2])
        rotate([-90,0,0])
            stepper(steppers[Z]);
    // X motor
    translate([-x_step[WIDTH]/2+plate_dims[0],
               x_step[LENGTH]+plate_thickness/2,
               -x_step[WIDTH]/2+plate_dims[2]])
        rotate([90,0,0])
            stepper(steppers[X]);
    // Z rod end
    rod_end(steppers[Z], rod_dia[Z], rod_spacing[Z],plate_thickness);
    // X rod end
    translate([plate_dims[X],0,plate_dims[Z]])
    rotate([0,90,180])
    rod_end(steppers[Z], rod_dia[Z], rod_spacing[Z],plate_thickness);
    // build volume
    //color(0.5,0.5,0.5,0.1)cube(build_volume);
}


// Trickle down parametrics
assembly(build_volume = build_volume,
         rod_dia = rod_dia,
         steppers = steppers,
         plate_thickness = plate_thickness,
         rod_spacing = rod_spacing);

