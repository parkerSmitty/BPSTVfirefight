shader_type spatial;

uniform int checker_size = 8;
uniform vec4 color1 : source_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 color2 : source_color = vec4(0.0,0.0,0.0,1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * float(checker_size);
	
	int x = int(floor(uv.x)) % 2;
	int y = int(floor(uv.y)) % 2:
	int sum = x + y;
	int checker = (x+y) % 2;
	
	vec4 final_color = (checker == 0) ? color1 : color2;
	
	ALBEDO = final_color.rgb
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
