include <Magpie/magpie.scad>; // https://github.com/sjkelly/Magpie/blob/master/docs/tutorial.md
include <config.scad>;

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

module plate(){
    color("tan")
    difference(){
        translate([0,-plate_thickness/2,0])cube(plate_dimensions);
        // Z motor
        translate([stepper_objs[2][WIDTH]/2,
                   -stepper_objs[2][LENGTH]-plate_thickness/2,
                   stepper_objs[2][WIDTH]/2])
            rotate([-90,0,0])
                stepper(steppers[2],diff=true,diff_length=plate_thickness*2);
        // X motor
        translate([-stepper_objs[0][WIDTH]/2+plate_dimensions[0],
                   stepper_objs[0][LENGTH]+plate_thickness/2,
                   -stepper_objs[0][WIDTH]/2+plate_dimensions[2]])
            rotate([90,0,0])
                stepper(steppers[0],diff=true,diff_length=plate_thickness*2);
    }
}

module rod_end(spacing=20){
    x_max = rod_dia[2]*2;
    z_max = stepper_objs[2][WIDTH];
    y_max = rod_spacing[2]+rod_dia[2]*2;
    translate([-x_max,-y_max/2,0])difference(){
        union(){
            cube([x_max,y_max,z_max]);
        }
        translate([x_max/2,rod_dia[2],-1])union(){
            polyCylinder(r=rod_dia[2]/2, h = z_max+2);
            translate([0,rod_spacing[2],0])polyCylinder(r=rod_dia[2]/2, h = z_max+2);
        }
    }
}

module assembly(build_volume, rod_dia, steppers, plate_thickness, rod_spacing){
    plate();
    // Z motor
    translate([stepper_objs[2][WIDTH]/2,
               -stepper_objs[2][LENGTH]-plate_thickness/2,
               stepper_objs[2][WIDTH]/2])
        rotate([-90,0,0])
            stepper(steppers[2]);
    // X motor
    translate([-stepper_objs[0][WIDTH]/2+plate_dimensions[0],
               stepper_objs[0][LENGTH]+plate_thickness/2,
               -stepper_objs[0][WIDTH]/2+plate_dimensions[2]])
        rotate([90,0,0])
            stepper(steppers[0]);
    rod_end();
    // build volume
    //color(0.5,0.5,0.5,0.1)cube(build_volume);
}

assembly(build_volume = build_volume,
         rod_dia = rod_dia,
         steppers = steppers,
         plate_thickness = plate_thickness,
         rod_spacing = rod_spacing);

