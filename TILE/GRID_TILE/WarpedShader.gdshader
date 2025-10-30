shader_type canvas_item;
uniform bool is_warped = false;

void fragment() {
	if (is_warped) {
	// Thanks, Iris!
    vec2 red_offset = vec2(abs((cos(TIME)*1.0/32.0/26.0)), 0.0);
    vec2 blue_offset = vec2(-abs((cos(TIME)*1.0/32.0/26.0)), 0.0);

    vec2 warp_offset = vec2(0.0001, 0.0);

    vec4 red = texture(TEXTURE, UV + blue_offset) - texture(TEXTURE, UV + red_offset);
    vec4 blue = texture(TEXTURE, UV + red_offset) - texture(TEXTURE, UV + blue_offset);
    vec4 green = texture(TEXTURE, UV);
    vec4 warp = ((texture(TEXTURE, UV - warp_offset)) + (texture(TEXTURE, UV + warp_offset))) - green;

    vec4 final_red = (red / green);
    vec4 final_blue = (blue / green);

    vec4 final = (red * green) + (blue * green) + warp;

    COLOR = vec4(red.a, 1.0 - green.g, blue.a, final.a);
	}

	else{
		vec4 letterTexture = texture(TEXTURE, UV);
		letterTexture.rgb *= 0.0;
		COLOR = letterTexture;
	}
}

void vertex() {
	if (is_warped) {
		VERTEX.x = VERTEX.x + cos(TIME) * 0.5;
	}
	else{
		VERTEX = VERTEX;
	}
}
