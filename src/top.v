










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
    
    /*
    wire [7:0] wire_external_data_out;
    always @(wire_external_data_out) begin
        external_data_out <= wire_external_data_out;
    end
    */



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
                wire_mem_src_ocea <= 1;
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
                wire_mem_src_wrea <= 1;
                wire_mem_src_ada <= 13'd0;
                wire_mem_src_dina <= 8'hAA;
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





















































