module top_mod (
    input clk,
    input rstn,

    output led,

    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,
    output [2:0] tmds_d_p_0
);

    wire [23:0] dvi_data;
    wire        dvi_den;
    wire        dvi_hsync;
    wire        dvi_vsync;
    wire        video_line_start;

    wire pll_lock;
    wire clk_p5;
    wire clk_p;
    wire sys_resetn;
    
// For Test ---------------------------------
//    reg r_led;
//    always @(posedge clk_p5) r_led <= ~r_led;
//    assign led = r_led;
//--------------------------------------------

    Gowin_PLL hdmi_pll (
        .clkin  (clk),
        .mdclk  (1'b0),
        .lock   (pll_lock),
        .clkout0(clk_p),
        .clkout1(clk_p5)
    );

    assign sys_resetn = (rstn & pll_lock);

    dvi_tx_top dvi_tx_top_inst0 (
        .pixel_clock  (clk_p),
        .ddr_bit_clock(clk_p5),
        .reset        (rstn),
        .den          (dvi_den),
        .hsync        (dvi_hsync),
        .vsync        (dvi_vsync),
        .pixel_data   (dvi_data),
        .tmds_clk     ({tmds_clk_p_0, tmds_clk_n_0}),
        .tmds_d0      ({tmds_d_p_0[0], tmds_d_n_0[0]}),
        .tmds_d1      ({tmds_d_p_0[1], tmds_d_n_0[1]}),
        .tmds_d2      ({tmds_d_p_0[2], tmds_d_n_0[2]})
    );

    test_pattern_gen test_gen0 (
        .pixel_clock      (clk_p),
        .reset            (~rstn),
        .video_vsync      (dvi_vsync),
        .video_hsync      (dvi_hsync),
        .video_den        (dvi_den),
        .video_pixel_even (dvi_data),
        .video_line_start (video_line_start)
    );

endmodule