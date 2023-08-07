



module inputbuffer (

    // input from arduino
    input wire [7:0] external_data_in,
    input wire external_data_clock,
    input wire external_reset,

    // output to ram
    output reg [12:0] ram_ad,
    output reg [7:0] ram_din,
    output reg ram_wre,
    output reg ram_ce,
    output reg ram_clk,

    // system clock
    input wire sysclk
);

    // output address register
    reg [12:0] addressregister;

    // global state machine
    reg [7:0] statemachine;

    // on systemclock
    always @(posedge sysclk) begin
        
        // are we in a reset condition?
        if (external_reset) begin
            // reset!
            addressregister <= 13'd0;
            statemachine <= 8'h00;
        end
        else begin
            // not a reset condition, do something!
            case (statemachine)

                //initialise and wait for external_data_clock
                8'h00 : begin
                    ram_wre <= 1'b0;
                    ram_ce <= 1'd0;
                    ram_clk <= 1'd0;
                    if (external_data_clock) statemachine <= 8'h01;
                end
                
                // initialise ram
                8'h01 : begin
                    ram_ce <= 1'b1;
                    ram_wre <= 1'b1;
                    ram_ad <= addressregister;
                    ram_din <= external_data_in;
                    statemachine <= 8'h02;
                end
                
                // clk up
                8'h02 : begin
                    ram_clk <= 1'b1;
                    statemachine <= 8'h03;
                end
                
                // clock down.
                8'h03 : begin
                    ram_clk <= 1'b0;
                    statemachine <= 8'h04;
                end
                
                // clean up
                8'h04 : begin
                    ram_ce <= 1'b0;
                    ram_wre <= 1'b0;
                    statemachine <= 8'h05;
                end

                // increment address index
                8'h05 : begin
                    addressregister <= addressregister + 1;
                    statemachine <= 8'h06;
                end
                
                // wait until end of clock pulse
                8'h06 : begin
                    if (!external_data_clock) statemachine <= 8'h00;
                end
                
                default: statemachine <= 8'h00;
            endcase
        end
    end

endmodule










module outputbuffer (
    
    // output to arduino
    output reg [7:0] external_data_out,
    input wire external_data_clock,
    input wire external_reset,

    // input from ram
    output reg [12:0] ram_ad,
    input wire [7:0] ram_dout,
    output reg ram_wre,
    output reg ram_ce,
    output reg ram_oce,
    output reg ram_clk,

    // sysclock
    input wire sysclk
);
    
    // the address register
    reg [12:0] addressregister;

    // the state machine
    reg [7:0] statemachine;


    // do things on sysclk time
    always @(posedge sysclk) begin
        
        // are we in a reset condition?
        if (external_reset) begin
            // reset condition!
        end
        else begin
            // not a reset, so do stuff!

            case (statemachine)

                //initialise and wait for external_data_clock
                8'h00 : begin
                    ram_wre <= 1'b0;
                    ram_ce <= 1'b0;
                    ram_oce <= 1'b0;
                    ram_clk <= 1'b0;
                    if (external_data_clock) statemachine <= 8'h01;
                end

                // turn on clocks and address
                8'h01 : begin
                    ram_ce <= 1'b1;
                    ram_oce <= 1'b1;
                    ram_ad <= addressregister;
                    statemachine <= 8'h02;
                end
                
                
                
                // clock high
                8'h02 : begin
                    ram_clk <= 1'b1;
                    statemachine <= 8'h03;
                end
                
                // clock low
                8'h03 : begin
                    ram_clk <= 1'b0;
                    statemachine <= 8'h04;
                end
                
                // read out data
                8'h04 : begin
                    external_data_out <= ram_dout;
                    statemachine <= 8'h05;
                end
                
                // clean up ram flags
                8'h05 : begin
                    ram_ce <= 1'b0;
                    ram_oce <= 1'b0;
                    statemachine <= 8'h06;
                end
                
                // increment address counter
                8'h06 : begin
                    addressregister <= addressregister + 1;
                    statemachine <= 8'h07;
                end
                
                // wait for end of external_data_clock pulse
                8'h07 : begin
                    if (!external_data_clock) statemachine <= 8'h00;
                end
                

                default: statemachine <= 8'h00;
            endcase
            
        end
    end

endmodule








module databankdemux (
    input wire [1:0] external_data_bank,
    input wire external_data_clock,
    output reg demux_clock_src,
    output reg demux_clock_key,
    output reg demux_clock_cmd,
    output reg demux_clock_dst
);

    always @(*) begin
        case (external_data_bank)
            2'b00 : begin
                demux_clock_src <= external_data_clock;
                demux_clock_key <= 1'b0;
                demux_clock_cmd <= 1'b0;
                demux_clock_dst <= 1'b0;
            end
            2'b01 : begin
                demux_clock_src <= 1'b0;
                demux_clock_key <= external_data_clock;
                demux_clock_cmd <= 1'b0;
                demux_clock_dst <= 1'b0;
            end
            2'b10 : begin
                demux_clock_src <= 1'b0;
                demux_clock_key <= 1'b0;
                demux_clock_cmd <= external_data_clock;
                demux_clock_dst <= 1'b0;
            end
            2'b11 : begin
                demux_clock_src <= 1'b0;
                demux_clock_key <= 1'b0;
                demux_clock_cmd <= 1'b0;
                demux_clock_dst <= external_data_clock;
            end
        endcase
    end
    
endmodule























module top (
    input wire [7:0] external_data_in,
    output reg [7:0] external_data_out,
    input wire [1:0] external_data_bank,
    input wire external_data_clock,
    input wire external_execute,
    output reg external_isfinished,
    input wire external_reset,
    input wire sysclk
);


    // external data out connector
    wire [7:0] wire_external_data_out;
    always @(wire_external_data_out) begin
        external_data_out <= wire_external_data_out;
    end




    // databank demuxer
    wire wire_demux_clock_src;
    wire wire_demux_clock_key;
    wire wire_demux_clock_cmd;
    wire wire_demux_clock_dst;

    databankdemux mydatabankdemux(  .external_data_bank(external_data_bank),
                                    .external_data_clock(external_data_clock),
                                    .demux_clock_src(wire_demux_clock_src),
                                    .demux_clock_key(wire_demux_clock_key),
                                    .demux_clock_cmd(wire_demux_clock_cmd),
                                    .demux_clock_dst(wire_demux_clock_dst)
                                    );



    // src memory block

    wire [7:0] wire_mem_src_douta;
    wire [7:0] wire_mem_src_doutb;
    wire wire_mem_src_clka;
    wire wire_mem_src_ocea;
    wire wire_mem_src_cea;
    wire wire_mem_src_reseta;
    wire wire_mem_src_wrea;
    wire wire_mem_src_clkb;
    wire wire_mem_src_oceb;
    wire wire_mem_src_ceb;
    wire wire_mem_src_resetb;
    wire wire_mem_src_wreb;
    wire [12:0] wire_mem_src_ada;
    wire [7:0] wire_mem_src_dina;
    wire [12:0] wire_mem_src_adb;
    wire [7:0] wire_mem_src_dinb;
    
    Gowin_DPB_8k blockmem_src(
        .douta(wire_mem_src_douta), //output [7:0] douta
        .doutb(wire_mem_src_doutb), //output [7:0] doutb
        .clka(wire_mem_src_clka), //input clka
        .ocea(wire_mem_src_ocea), //input ocea
        .cea(wire_mem_src_cea), //input cea
        .reseta(wire_mem_src_reseta), //input reseta
        .wrea(wire_mem_src_wrea), //input wrea
        .clkb(wire_mem_src_clkb), //input clkb
        .oceb(wire_mem_src_oceb), //input oceb
        .ceb(wire_mem_src_ceb), //input ceb
        .resetb(wire_mem_src_resetb), //input resetb
        .wreb(wire_mem_src_wreb), //input wreb
        .ada(wire_mem_src_ada), //input [12:0] ada
        .dina(wire_mem_src_dina), //input [7:0] dina
        .adb(wire_mem_src_adb), //input [12:0] adb
        .dinb(wire_mem_src_dinb) //input [7:0] dinb
    );

    // input buffer for src
    inputbuffer buffer_src( .external_data_in(external_data_in),
                            .external_data_clock(wire_demux_clock_src),
                            .external_reset(external_reset),
                            .ram_ad(wire_mem_src_ada),
                            .ram_din(wire_mem_src_dina),
                            .ram_wre(wire_mem_src_wrea),
                            .ram_ce(wire_mem_src_cea),
                            .ram_clk(wire_mem_src_clka),
                            .sysclk(sysclk)
                            );





    // key memory block


    wire [7:0] wire_mem_key_douta;
    wire [7:0] wire_mem_key_doutb;
    wire wire_mem_key_clka;
    wire wire_mem_key_ocea;
    wire wire_mem_key_cea;
    wire wire_mem_key_reseta;
    wire wire_mem_key_wrea;
    wire wire_mem_key_clkb;
    wire wire_mem_key_oceb;
    wire wire_mem_key_ceb;
    wire wire_mem_key_resetb;
    wire wire_mem_key_wreb;
    wire [12:0] wire_mem_key_ada;
    wire [7:0] wire_mem_key_dina;
    wire [12:0] wire_mem_key_adb;
    wire [7:0] wire_mem_key_dinb;
    
    Gowin_DPB_8k blockmem_key(
        .douta(wire_mem_key_douta), //output [7:0] douta
        .doutb(wire_mem_key_doutb), //output [7:0] doutb
        .clka(wire_mem_key_clka), //input clka
        .ocea(wire_mem_key_ocea), //input ocea
        .cea(wire_mem_key_cea), //input cea
        .reseta(wire_mem_key_reseta), //input reseta
        .wrea(wire_mem_key_wrea), //input wrea
        .clkb(wire_mem_key_clkb), //input clkb
        .oceb(wire_mem_key_oceb), //input oceb
        .ceb(wire_mem_key_ceb), //input ceb
        .resetb(wire_mem_key_resetb), //input resetb
        .wreb(wire_mem_key_wreb), //input wreb
        .ada(wire_mem_key_ada), //input [12:0] ada
        .dina(wire_mem_key_dina), //input [7:0] dina
        .adb(wire_mem_key_adb), //input [12:0] adb
        .dinb(wire_mem_key_dinb) //input [7:0] dinb
    );

    // input buffer for key
    inputbuffer buffer_key( .external_data_in(external_data_in),
                            .external_data_clock(wire_demux_clock_key),
                            .external_reset(external_reset),
                            .ram_ad(wire_mem_key_ada),
                            .ram_din(wire_mem_key_dina),
                            .ram_wre(wire_mem_key_wrea),
                            .ram_ce(wire_mem_key_cea),
                            .ram_clk(wire_mem_key_clka),
                            .sysclk(sysclk)
                            );




    // cmd memory block


    wire [7:0] wire_mem_cmd_douta;
    wire [7:0] wire_mem_cmd_doutb;
    wire wire_mem_cmd_clka;
    wire wire_mem_cmd_ocea;
    wire wire_mem_cmd_cea;
    wire wire_mem_cmd_reseta;
    wire wire_mem_cmd_wrea;
    wire wire_mem_cmd_clkb;
    wire wire_mem_cmd_oceb;
    wire wire_mem_cmd_ceb;
    wire wire_mem_cmd_resetb;
    wire wire_mem_cmd_wreb;
    wire [12:0] wire_mem_cmd_ada;
    wire [7:0] wire_mem_cmd_dina;
    wire [12:0] wire_mem_cmd_adb;
    wire [7:0] wire_mem_cmd_dinb;
    
    Gowin_DPB_8k blockmem_cmd(
        .douta(wire_mem_cmd_douta), //output [7:0] douta
        .doutb(wire_mem_cmd_doutb), //output [7:0] doutb
        .clka(wire_mem_cmd_clka), //input clka
        .ocea(wire_mem_cmd_ocea), //input ocea
        .cea(wire_mem_cmd_cea), //input cea
        .reseta(wire_mem_cmd_reseta), //input reseta
        .wrea(wire_mem_cmd_wrea), //input wrea
        .clkb(wire_mem_cmd_clkb), //input clkb
        .oceb(wire_mem_cmd_oceb), //input oceb
        .ceb(wire_mem_cmd_ceb), //input ceb
        .resetb(wire_mem_cmd_resetb), //input resetb
        .wreb(wire_mem_cmd_wreb), //input wreb
        .ada(wire_mem_cmd_ada), //input [12:0] ada
        .dina(wire_mem_cmd_dina), //input [7:0] dina
        .adb(wire_mem_cmd_adb), //input [12:0] adb
        .dinb(wire_mem_cmd_dinb) //input [7:0] dinb
    );

    // input buffer for cmd
    inputbuffer buffer_cmd( .external_data_in(external_data_in),
                            .external_data_clock(wire_demux_clock_cmd),
                            .external_reset(external_reset),
                            .ram_ad(wire_mem_cmd_ada),
                            .ram_din(wire_mem_cmd_dina),
                            .ram_wre(wire_mem_cmd_wrea),
                            .ram_ce(wire_mem_cmd_cea),
                            .ram_clk(wire_mem_cmd_clka),
                            .sysclk(sysclk)
                            );




    // dst memory block


    wire [7:0] wire_mem_dst_douta;
    wire [7:0] wire_mem_dst_doutb;
    wire wire_mem_dst_clka;
    wire wire_mem_dst_ocea;
    wire wire_mem_dst_cea;
    wire wire_mem_dst_reseta;
    wire wire_mem_dst_wrea;
    wire wire_mem_dst_clkb;
    wire wire_mem_dst_oceb;
    wire wire_mem_dst_ceb;
    wire wire_mem_dst_resetb;
    wire wire_mem_dst_wreb;
    wire [12:0] wire_mem_dst_ada;
    wire [7:0] wire_mem_dst_dina;
    wire [12:0] wire_mem_dst_adb;
    wire [7:0] wire_mem_dst_dinb;
    
    Gowin_DPB_8k blockmem_dst(
        .douta(wire_mem_dst_douta), //output [7:0] douta
        .doutb(wire_mem_dst_doutb), //output [7:0] doutb
        .clka(wire_mem_dst_clka), //input clka
        .ocea(wire_mem_dst_ocea), //input ocea
        .cea(wire_mem_dst_cea), //input cea
        .reseta(wire_mem_dst_reseta), //input reseta
        .wrea(wire_mem_dst_wrea), //input wrea
        .clkb(wire_mem_dst_clkb), //input clkb
        .oceb(wire_mem_dst_oceb), //input oceb
        .ceb(wire_mem_dst_ceb), //input ceb
        .resetb(wire_mem_dst_resetb), //input resetb
        .wreb(wire_mem_dst_wreb), //input wreb
        .ada(wire_mem_dst_ada), //input [12:0] ada
        .dina(wire_mem_dst_dina), //input [7:0] dina
        .adb(wire_mem_dst_adb), //input [12:0] adb
        .dinb(wire_mem_dst_dinb) //input [7:0] dinb
    );

    // add output buffer this time
    outputbuffer buffer_dst(    .external_data_out(wire_external_data_out),
                                .external_data_clock(external_data_clock),
                                .external_reset(external_reset),
                                .ram_ad(wire_mem_dst_ada),
                                .ram_dout(wire_mem_dst_douta),
                                .ram_wre(wire_mem_dst_wrea),
                                .ram_ce(wire_mem_dst_cea),
                                .ram_oce(wire_mem_dst_ocea),
                                .ram_clk(wire_mem_dst_clka),
                                .sysclk(sysclk)
                                );



endmodule



















































/*

module top (
    input wire [7:0] external_data_in,
    output reg [7:0] external_data_out,
    input wire [1:0] external_data_bank,
    input wire external_data_clock,
    input wire external_execute,
    output reg external_isfinished,
    input wire external_reset,
    input wire sysclk
);
    
    
    // wire [7:0] wire_external_data_out;
    // always @(wire_external_data_out) begin
    //     external_data_out <= wire_external_data_out;
    // end
    



    wire [7:0] wire_mem_src_douta;
    wire [7:0] wire_mem_src_doutb;
    reg wire_mem_src_clka;
    reg wire_mem_src_ocea;
    reg wire_mem_src_cea;
    reg wire_mem_src_reseta;
    reg wire_mem_src_wrea;
    reg wire_mem_src_clkb;
    reg wire_mem_src_oceb;
    reg wire_mem_src_ceb;
    reg wire_mem_src_resetb;
    reg wire_mem_src_wreb;
    reg [12:0] wire_mem_src_ada;
    reg [7:0] wire_mem_src_dina;
    reg [12:0] wire_mem_src_adb;
    reg [7:0] wire_mem_src_dinb;
    

    Gowin_DPB_8k blockmem_src(
        .douta(wire_mem_src_douta), //output [7:0] douta
        .doutb(wire_mem_src_doutb), //output [7:0] doutb
        .clka(wire_mem_src_clka), //input clka
        .ocea(wire_mem_src_ocea), //input ocea
        .cea(wire_mem_src_cea), //input cea
        .reseta(wire_mem_src_reseta), //input reseta
        .wrea(wire_mem_src_wrea), //input wrea
        .clkb(wire_mem_src_clkb), //input clkb
        .oceb(wire_mem_src_oceb), //input oceb
        .ceb(wire_mem_src_ceb), //input ceb
        .resetb(wire_mem_src_resetb), //input resetb
        .wreb(wire_mem_src_wreb), //input wreb
        .ada(wire_mem_src_ada), //input [12:0] ada
        .dina(wire_mem_src_dina), //input [7:0] dina
        .adb(wire_mem_src_adb), //input [12:0] adb
        .dinb(wire_mem_src_dinb) //input [7:0] dinb
    );


    


    reg [7:0] dataregisterA;



    reg [7:0] statemachine;

    always @(posedge sysclk) begin
        if (external_reset) statemachine <= 8'h00;
        case (statemachine)
            // initialise
            8'h00 : begin
                wire_mem_src_clka <= 1'b0;
                wire_mem_src_ocea <= 1'b0;
                wire_mem_src_cea <= 1'b0;
                wire_mem_src_reseta <= 1'b0;
                wire_mem_src_wrea <= 1'b0;
                wire_mem_src_ada <= 13'd0;
                wire_mem_src_dina <= 8'd0;
                if (external_execute) statemachine <= 8'h10;
            end

            // 1 clk 0
            8'h10 : begin
                external_isfinished <= 1'b0;
                wire_mem_src_clka <= 1'b0;
                statemachine <= 8'h18;
            end
            

            // 1 clk 0
            8'h18 : begin
                wire_mem_src_clka <= 1'b0;
                wire_mem_src_cea <= 1;
                //wire_mem_src_ocea <= 1;
                statemachine <= 8'h20;
            end
            

            // 2 clk 1
            8'h20 : begin
                wire_mem_src_clka <= 1'b1;
                statemachine <= 8'h28;
            end
            

            // 2 clk 0
            8'h28 : begin
                wire_mem_src_clka <= 1'b0;
                wire_mem_src_wrea <= 1'b1;
                wire_mem_src_ada <= 13'd0;
                wire_mem_src_dina <= 8'hBE;
                statemachine <= 8'h30;
            end

            // 3 clk 1
            
            8'h30 : begin
                wire_mem_src_clka <= 1'b1;
                statemachine <= 8'h38;
            end
            
            // 3 clk 0
            8'h38 : begin
                wire_mem_src_clka <= 1'b0;
                wire_mem_src_wrea <= 1'b0;
                wire_mem_src_cea <= 1'b0;
                wire_mem_src_ocea <= 1'b0;
                statemachine <= 8'h40;
            end


            // at this point, write is complete.
            // memory location 0 contains 0x55;
            
            8'h40 : begin
                // no-op
                statemachine <= 8'h58;
                wire_mem_src_cea <= 1'b1;
                wire_mem_src_ocea <= 1'b1;
                wire_mem_src_wrea <= 1'b0;
            end


            // 5 clk 0;
            8'h58 : begin
                wire_mem_src_clka <= 1'b0;
                wire_mem_src_ada <= 13'd0;
                statemachine <= 8'h60;
            end

            // 6 clk 1
            8'h60 : begin
                wire_mem_src_clka <= 1'b1;
                statemachine <= 8'h68;
            end

            // 6 clk 0
            8'h68 : begin
                wire_mem_src_clka <= 1'b0;
                external_data_out <= wire_mem_src_douta;
                statemachine <= 8'hFF;
            end

            8'hFF : begin
                external_isfinished <= 1'b1;
            end



            // at this point, data is copied to dataout


            

        endcase

    end




endmodule



*/

















































