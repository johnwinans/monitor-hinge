
all: stl/mon_left.stl stl/mon_right.stl stl/ub_left.stl stl/ub_right.stl

# define this for mounting with a Drywall screw
MOUNT_BOLT_DIA=-Duni_bolt_dia=5

# define this for mounting with a 3/8" bolt (useful for Unistrut)
# MOUNT_BOLT_DIA=-Duni_bolt_dia=10

stl/ub_left.stl: monitor_hinge.scad
	openscad ${MOUNT_BOLT_DIA} -Dmake_this=1 -o $@ $<
stl/ub_right.stl: monitor_hinge.scad
	openscad ${MOUNT_BOLT_DIA} -Dmake_this=2 -o $@ $<
stl/mon_left.stl: monitor_hinge.scad
	openscad ${MOUNT_BOLT_DIA} -Dmake_this=3 -o $@ $<
stl/mon_right.stl: monitor_hinge.scad
	openscad ${MOUNT_BOLT_DIA} -Dmake_this=4 -o $@ $<

clean::
	rm -f stl/*.stl

world:: clean all
