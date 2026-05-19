`timescale 1ns / 1ns

module test_pattern_gen #(
	
	parameter video_hlength		= 2200,// Total H length
	parameter video_vlength		= 1125,// Total v length
	parameter video_hsync_pol	= 1,   // 
	parameter video_hsync_len	= 44,  // HSYNC pulse width
	parameter video_hbp_len		= 148, // horizontal backporch
	
	parameter video_h_visible	= 1920,// horizontal visible
	parameter video_vsync_pol	= 1,   
	parameter video_vsync_len	= 5,   // VSYNC pulse width
	parameter video_vbp_len		= 36,  // vertical back porch
	parameter video_v_visible	= 1080 // vertical visible
)
(
	input				pixel_clock,
	input				reset,
	
	output				video_vsync,
	output				video_hsync,
	output				video_den,
	output				video_line_start,
	output	[23 : 0]	video_pixel_even,
	output	[23 : 0]	video_pixel_odd
);
	

/*
	What Happens on Every Pixel Clock?
	1. h_pos increments
	2. timing signals updated
	3. visible region checked
	4. current pixel generated
	5. RGB values transmitted
*/

	wire	[3 : 0]		pattern_index;
	wire	[23 : 0]	pattern_value;
	
	reg		[23 : 0]	pattern_colours_t [15 : 0];
	
	wire				den_int;
	wire	[13 : 0]	pixel_x;
	wire	[13 : 0]	pixel_y;
	
	initial begin
		// Color Format = 			 R__G__B
		pattern_colours_t[0]  <= 24'hFF_00_00; // Red
		pattern_colours_t[1]  <= 24'hFF_7F_00; // Orange
		pattern_colours_t[2]  <= 24'hFF_FF_00; // Yellow
		pattern_colours_t[3]  <= 24'h7F_FF_00; // Lime
		pattern_colours_t[4]  <= 24'h00_FF_00; // Green
		pattern_colours_t[5]  <= 24'h00_FF_7F; // Spring Green
		pattern_colours_t[6]  <= 24'h00_FF_FF; // Cyan
		pattern_colours_t[7]  <= 24'h00_7F_FF; // Sky Blue
		pattern_colours_t[8]  <= 24'h00_00_FF; // Blue
		pattern_colours_t[9]  <= 24'h7F_00_FF; // Violet
		pattern_colours_t[10] <= 24'hFF_00_FF; // Magenta
		pattern_colours_t[11] <= 24'hFF_00_7F; // Pink

		pattern_colours_t[12] <= 24'hFF_FF_FF; // White
		pattern_colours_t[13] <= 24'hC0_C0_C0; // Silver
		pattern_colours_t[14] <= 24'h40_40_40; // Dark Gray
		pattern_colours_t[15] <= 24'h00_00_00; // Black
	end
	
	assign pattern_index = pixel_x[7 +: 4];
	assign pattern_value = pattern_colours_t[pattern_index];
	
	assign video_pixel_even = (den_int) ? pattern_value : 24'h000000;
	assign video_pixel_odd = (den_int) ? pattern_value : 24'h000000;
	
	assign video_den = den_int;
	
	// First pixel @(h_pos, v_pos) = (192,41)
	video_timing_ctrl #(
		
		.video_hlength(video_hlength),
		.video_vlength(video_vlength),
		
		.video_hsync_pol(video_hsync_pol),
		.video_hsync_len(video_hsync_len),
		.video_hbp_len(video_hbp_len),
		.video_h_visible(video_h_visible),
		
		.video_vsync_pol(video_vsync_pol),
		.video_vsync_len(video_vsync_len),
		.video_vbp_len(video_vbp_len),
		.video_v_visible(video_v_visible)
		
	)video_timing_ctrl_inst0(
		
		.pixel_clock		(pixel_clock),
		.reset				(reset),
		.ext_sync			(1'b0),
		
		.timing_h_pos		(),
		.timing_v_pos		(),
		.pixel_x			(pixel_x),
		.pixel_y			(pixel_y),
		
		.video_vsync		(video_vsync),
		.video_hsync		(video_hsync),
		.video_den			(den_int),
		.video_line_start	(video_line_start)
	);
	
endmodule
