module Broadcast #(parameter OUT_BIT = 32, parameter LOW_PRE = 0, parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8, parameter MAC_R = 32)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C-1:0],
    input wire[INWID*4-1:0] act_reg[STEP_LEN*MAC_R-1:0],
    output reg[INWID*4-1:0] wgt_arr[STEP_LEN*MAC_R*MAC_C-1:0],
    output reg[INWID*4-1:0] act_arr[STEP_LEN*MAC_R*MAC_C-1:0]
    );
    genvar i,j;
    generate
        for (i=0;i<MAC_R*MAC_C;i=i+1) begin: wgt_gen
            assign wgt_arr[(i+1)*STEP_LEN-1:i*STEP_LEN] = wgt_reg[(i%MAC_C+1)*STEP_LEN-1:(i%MAC_C)*STEP_LEN];
        end
    endgenerate
    generate
        for (j=0;j<MAC_R*MAC_C;j=j+1) begin: act_gen
            assign act_arr[(j+1)*STEP_LEN-1:j*STEP_LEN] = act_reg[(j%MAC_R+1)*STEP_LEN-1:(j%MAC_R)*STEP_LEN];
        end
    endgenerate
endmodule

module Unicast #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8, parameter MAC_R = 32, parameter TILE = 8) (
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*TILE-1:0],
    input wire[INWID*4-1:0] act_reg[STEP_LEN*MAC_C*MAC_R-1:0],
    input wire[7:0] msk[MAC_R-1:0],
    output reg[INWID*4-1:0] wgt_arr[STEP_LEN*MAC_R*MAC_C-1:0],
    output reg[INWID*4-1:0] act_arr[STEP_LEN*MAC_R*MAC_C-1:0]
);
    genvar i,j;
    generate
        if (TILE == 8) begin
            for (i=0;i<MAC_R;i=i+1) begin: wgt_gen
                SelectReg_8 #(.INWID(INWID),.STEP_LEN(STEP_LEN),.MAC_C(MAC_C)) mux(
                    .wgt_reg(wgt_reg),
                    .msk(msk[i]),
                    .wgt_vec(wgt_arr[(i+1)*STEP_LEN*MAC_C-1:i*STEP_LEN*MAC_C]));
            end
        end
        else if (TILE == 64) begin
            for (i=0;i<MAC_R;i=i+1) begin: wgt_gen
                SelectReg_64 #(.INWID(INWID),.STEP_LEN(STEP_LEN),.MAC_C(MAC_C)) mux(
                    .wgt_reg(wgt_reg),
                    .msk(msk[i]),
                    .wgt_vec(wgt_arr[(i+1)*STEP_LEN*MAC_C-1:i*STEP_LEN*MAC_C]));
            end            
        end
        else if (TILE == 32) begin
            for (i=0;i<MAC_R;i=i+1) begin: wgt_gen
                SelectReg_32 #(.INWID(INWID),.STEP_LEN(STEP_LEN),.MAC_C(MAC_C)) mux(
                    .wgt_reg(wgt_reg),
                    .msk(msk[i]),
                    .wgt_vec(wgt_arr[(i+1)*STEP_LEN*MAC_C-1:i*STEP_LEN*MAC_C]));
            end            
        end
        else if (TILE == 16) begin
            for (i=0;i<MAC_R;i=i+1) begin: wgt_gen
                SelectReg_16 #(.INWID(INWID),.STEP_LEN(STEP_LEN),.MAC_C(MAC_C)) mux(
                    .wgt_reg(wgt_reg),
                    .msk(msk[i]),
                    .wgt_vec(wgt_arr[(i+1)*STEP_LEN*MAC_C-1:i*STEP_LEN*MAC_C]));
            end            
        end
        else if (TILE == 128) begin
            for (i=0;i<MAC_R;i=i+1) begin: wgt_gen
                SelectReg_128 #(.INWID(INWID),.STEP_LEN(STEP_LEN),.MAC_C(MAC_C)) mux(
                    .wgt_reg(wgt_reg),
                    .msk(msk[i]),
                    .wgt_vec(wgt_arr[(i+1)*STEP_LEN*MAC_C-1:i*STEP_LEN*MAC_C]));
            end            
        end
    endgenerate
    assign  act_arr = act_reg;
endmodule



module SelectReg_8 #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*8-1:0],
    input wire[7:0] msk,
    output reg[INWID*4-1:0] wgt_vec[STEP_LEN*MAC_C-1:0]
);
    always_comb begin
        case(msk)
            3'b000: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
            3'b001: wgt_vec = wgt_reg[STEP_LEN*MAC_C*2-1:STEP_LEN*MAC_C*1];
            3'b010: wgt_vec = wgt_reg[STEP_LEN*MAC_C*3-1:STEP_LEN*MAC_C*2];
            3'b011: wgt_vec = wgt_reg[STEP_LEN*MAC_C*4-1:STEP_LEN*MAC_C*3];
            3'b100: wgt_vec = wgt_reg[STEP_LEN*MAC_C*5-1:STEP_LEN*MAC_C*4];
            3'b101: wgt_vec = wgt_reg[STEP_LEN*MAC_C*6-1:STEP_LEN*MAC_C*5];
            3'b110: wgt_vec = wgt_reg[STEP_LEN*MAC_C*7-1:STEP_LEN*MAC_C*6];
            3'b111: wgt_vec = wgt_reg[STEP_LEN*MAC_C*8-1:STEP_LEN*MAC_C*7];
            default: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
        endcase
    end
endmodule

module SelectReg_16 #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*16-1:0],
    input wire[7:0] msk,
    output reg[INWID*4-1:0] wgt_vec[STEP_LEN*MAC_C-1:0]
);
    always_comb begin
        case(msk)
            4'd00: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];                   4'd01: wgt_vec = wgt_reg[STEP_LEN*MAC_C*2-1:STEP_LEN*MAC_C*1];
            4'd02: wgt_vec = wgt_reg[STEP_LEN*MAC_C*3-1:STEP_LEN*MAC_C*2];  4'd03: wgt_vec = wgt_reg[STEP_LEN*MAC_C*4-1:STEP_LEN*MAC_C*3];
            4'd04: wgt_vec = wgt_reg[STEP_LEN*MAC_C*5-1:STEP_LEN*MAC_C*4];  4'd05: wgt_vec = wgt_reg[STEP_LEN*MAC_C*6-1:STEP_LEN*MAC_C*5];
            4'd06: wgt_vec = wgt_reg[STEP_LEN*MAC_C*7-1:STEP_LEN*MAC_C*6];  4'd07: wgt_vec = wgt_reg[STEP_LEN*MAC_C*8-1:STEP_LEN*MAC_C*7];
            4'd08: wgt_vec = wgt_reg[STEP_LEN*MAC_C*9-1:STEP_LEN*MAC_C*8];  4'd09: wgt_vec = wgt_reg[STEP_LEN*MAC_C*10-1:STEP_LEN*MAC_C*9];
            4'd10: wgt_vec = wgt_reg[STEP_LEN*MAC_C*11-1:STEP_LEN*MAC_C*10];4'd11: wgt_vec = wgt_reg[STEP_LEN*MAC_C*12-1:STEP_LEN*MAC_C*11];
            4'd12: wgt_vec = wgt_reg[STEP_LEN*MAC_C*13-1:STEP_LEN*MAC_C*12];4'd13: wgt_vec = wgt_reg[STEP_LEN*MAC_C*14-1:STEP_LEN*MAC_C*13];
            4'd14: wgt_vec = wgt_reg[STEP_LEN*MAC_C*15-1:STEP_LEN*MAC_C*14];4'd15: wgt_vec = wgt_reg[STEP_LEN*MAC_C*16-1:STEP_LEN*MAC_C*15];
            default: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
        endcase
    end
endmodule


module SelectReg_32 #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*32-1:0],
    input wire[7:0] msk,
    output reg[INWID*4-1:0] wgt_vec[STEP_LEN*MAC_C-1:0]
);
    always_comb begin
        case(msk)
            5'd00: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];                   5'd01: wgt_vec = wgt_reg[STEP_LEN*MAC_C*2-1:STEP_LEN*MAC_C*1];
            5'd02: wgt_vec = wgt_reg[STEP_LEN*MAC_C*3-1:STEP_LEN*MAC_C*2];  5'd03: wgt_vec = wgt_reg[STEP_LEN*MAC_C*4-1:STEP_LEN*MAC_C*3];
            5'd04: wgt_vec = wgt_reg[STEP_LEN*MAC_C*5-1:STEP_LEN*MAC_C*4];  5'd05: wgt_vec = wgt_reg[STEP_LEN*MAC_C*6-1:STEP_LEN*MAC_C*5];
            5'd06: wgt_vec = wgt_reg[STEP_LEN*MAC_C*7-1:STEP_LEN*MAC_C*6];  5'd07: wgt_vec = wgt_reg[STEP_LEN*MAC_C*8-1:STEP_LEN*MAC_C*7];
            5'd08: wgt_vec = wgt_reg[STEP_LEN*MAC_C*9-1:STEP_LEN*MAC_C*8];  5'd09: wgt_vec = wgt_reg[STEP_LEN*MAC_C*10-1:STEP_LEN*MAC_C*9];
            5'd10: wgt_vec = wgt_reg[STEP_LEN*MAC_C*11-1:STEP_LEN*MAC_C*10];5'd11: wgt_vec = wgt_reg[STEP_LEN*MAC_C*12-1:STEP_LEN*MAC_C*11];
            5'd12: wgt_vec = wgt_reg[STEP_LEN*MAC_C*13-1:STEP_LEN*MAC_C*12];5'd13: wgt_vec = wgt_reg[STEP_LEN*MAC_C*14-1:STEP_LEN*MAC_C*13];
            5'd14: wgt_vec = wgt_reg[STEP_LEN*MAC_C*15-1:STEP_LEN*MAC_C*14];5'd15: wgt_vec = wgt_reg[STEP_LEN*MAC_C*16-1:STEP_LEN*MAC_C*15];
            5'd16: wgt_vec = wgt_reg[STEP_LEN*MAC_C*17-1:STEP_LEN*MAC_C*16];5'd17: wgt_vec = wgt_reg[STEP_LEN*MAC_C*18-1:STEP_LEN*MAC_C*17];
            5'd18: wgt_vec = wgt_reg[STEP_LEN*MAC_C*19-1:STEP_LEN*MAC_C*18];5'd19: wgt_vec = wgt_reg[STEP_LEN*MAC_C*20-1:STEP_LEN*MAC_C*19];
            5'd20: wgt_vec = wgt_reg[STEP_LEN*MAC_C*21-1:STEP_LEN*MAC_C*20];5'd21: wgt_vec = wgt_reg[STEP_LEN*MAC_C*22-1:STEP_LEN*MAC_C*21];
            5'd22: wgt_vec = wgt_reg[STEP_LEN*MAC_C*23-1:STEP_LEN*MAC_C*22];5'd23: wgt_vec = wgt_reg[STEP_LEN*MAC_C*24-1:STEP_LEN*MAC_C*23];
            5'd24: wgt_vec = wgt_reg[STEP_LEN*MAC_C*25-1:STEP_LEN*MAC_C*24];5'd25: wgt_vec = wgt_reg[STEP_LEN*MAC_C*26-1:STEP_LEN*MAC_C*25];
            5'd26: wgt_vec = wgt_reg[STEP_LEN*MAC_C*27-1:STEP_LEN*MAC_C*26];5'd27: wgt_vec = wgt_reg[STEP_LEN*MAC_C*28-1:STEP_LEN*MAC_C*27];
            5'd28: wgt_vec = wgt_reg[STEP_LEN*MAC_C*29-1:STEP_LEN*MAC_C*28];5'd29: wgt_vec = wgt_reg[STEP_LEN*MAC_C*30-1:STEP_LEN*MAC_C*29];
            5'd30: wgt_vec = wgt_reg[STEP_LEN*MAC_C*31-1:STEP_LEN*MAC_C*30];5'd31: wgt_vec = wgt_reg[STEP_LEN*MAC_C*32-1:STEP_LEN*MAC_C*31];
            default: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
        endcase
    end
endmodule


module SelectReg_64 #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*64-1:0],
    input wire[7:0] msk,
    output reg[INWID*4-1:0] wgt_vec[STEP_LEN*MAC_C-1:0]
);
    always_comb begin
        case(msk)
            8'd000: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];                   8'd001: wgt_vec = wgt_reg[STEP_LEN*MAC_C*2-1:STEP_LEN*MAC_C*1];
            8'd002: wgt_vec = wgt_reg[STEP_LEN*MAC_C*3-1:STEP_LEN*MAC_C*2];  8'd003: wgt_vec = wgt_reg[STEP_LEN*MAC_C*4-1:STEP_LEN*MAC_C*3];
            8'd004: wgt_vec = wgt_reg[STEP_LEN*MAC_C*5-1:STEP_LEN*MAC_C*4];  8'd005: wgt_vec = wgt_reg[STEP_LEN*MAC_C*6-1:STEP_LEN*MAC_C*5];
            8'd006: wgt_vec = wgt_reg[STEP_LEN*MAC_C*7-1:STEP_LEN*MAC_C*6];  8'd007: wgt_vec = wgt_reg[STEP_LEN*MAC_C*8-1:STEP_LEN*MAC_C*7];
            8'd008: wgt_vec = wgt_reg[STEP_LEN*MAC_C*9-1:STEP_LEN*MAC_C*8];  8'd009: wgt_vec = wgt_reg[STEP_LEN*MAC_C*10-1:STEP_LEN*MAC_C*9];
            8'd010: wgt_vec = wgt_reg[STEP_LEN*MAC_C*11-1:STEP_LEN*MAC_C*10];8'd011: wgt_vec = wgt_reg[STEP_LEN*MAC_C*12-1:STEP_LEN*MAC_C*11];
            8'd012: wgt_vec = wgt_reg[STEP_LEN*MAC_C*13-1:STEP_LEN*MAC_C*12];8'd013: wgt_vec = wgt_reg[STEP_LEN*MAC_C*14-1:STEP_LEN*MAC_C*13];
            8'd014: wgt_vec = wgt_reg[STEP_LEN*MAC_C*15-1:STEP_LEN*MAC_C*14];8'd015: wgt_vec = wgt_reg[STEP_LEN*MAC_C*16-1:STEP_LEN*MAC_C*15];
            8'd016: wgt_vec = wgt_reg[STEP_LEN*MAC_C*17-1:STEP_LEN*MAC_C*16];8'd017: wgt_vec = wgt_reg[STEP_LEN*MAC_C*18-1:STEP_LEN*MAC_C*17];
            8'd018: wgt_vec = wgt_reg[STEP_LEN*MAC_C*19-1:STEP_LEN*MAC_C*18];8'd019: wgt_vec = wgt_reg[STEP_LEN*MAC_C*20-1:STEP_LEN*MAC_C*19];
            8'd020: wgt_vec = wgt_reg[STEP_LEN*MAC_C*21-1:STEP_LEN*MAC_C*20];8'd021: wgt_vec = wgt_reg[STEP_LEN*MAC_C*22-1:STEP_LEN*MAC_C*21];
            8'd022: wgt_vec = wgt_reg[STEP_LEN*MAC_C*23-1:STEP_LEN*MAC_C*22];8'd023: wgt_vec = wgt_reg[STEP_LEN*MAC_C*24-1:STEP_LEN*MAC_C*23];
            8'd024: wgt_vec = wgt_reg[STEP_LEN*MAC_C*25-1:STEP_LEN*MAC_C*24];8'd025: wgt_vec = wgt_reg[STEP_LEN*MAC_C*26-1:STEP_LEN*MAC_C*25];
            8'd026: wgt_vec = wgt_reg[STEP_LEN*MAC_C*27-1:STEP_LEN*MAC_C*26];8'd027: wgt_vec = wgt_reg[STEP_LEN*MAC_C*28-1:STEP_LEN*MAC_C*27];
            8'd028: wgt_vec = wgt_reg[STEP_LEN*MAC_C*29-1:STEP_LEN*MAC_C*28];8'd029: wgt_vec = wgt_reg[STEP_LEN*MAC_C*30-1:STEP_LEN*MAC_C*29];
            8'd030: wgt_vec = wgt_reg[STEP_LEN*MAC_C*31-1:STEP_LEN*MAC_C*30];8'd031: wgt_vec = wgt_reg[STEP_LEN*MAC_C*32-1:STEP_LEN*MAC_C*31];
            8'd032: wgt_vec = wgt_reg[STEP_LEN*MAC_C*33-1:STEP_LEN*MAC_C*32];8'd033: wgt_vec = wgt_reg[STEP_LEN*MAC_C*34-1:STEP_LEN*MAC_C*33];
            8'd034: wgt_vec = wgt_reg[STEP_LEN*MAC_C*35-1:STEP_LEN*MAC_C*34];8'd035: wgt_vec = wgt_reg[STEP_LEN*MAC_C*36-1:STEP_LEN*MAC_C*35];
            8'd036: wgt_vec = wgt_reg[STEP_LEN*MAC_C*37-1:STEP_LEN*MAC_C*36];8'd037: wgt_vec = wgt_reg[STEP_LEN*MAC_C*38-1:STEP_LEN*MAC_C*37];
            8'd038: wgt_vec = wgt_reg[STEP_LEN*MAC_C*39-1:STEP_LEN*MAC_C*38];8'd039: wgt_vec = wgt_reg[STEP_LEN*MAC_C*40-1:STEP_LEN*MAC_C*39];
            8'd040: wgt_vec = wgt_reg[STEP_LEN*MAC_C*41-1:STEP_LEN*MAC_C*40];8'd041: wgt_vec = wgt_reg[STEP_LEN*MAC_C*42-1:STEP_LEN*MAC_C*41];
            8'd042: wgt_vec = wgt_reg[STEP_LEN*MAC_C*43-1:STEP_LEN*MAC_C*42];8'd043: wgt_vec = wgt_reg[STEP_LEN*MAC_C*44-1:STEP_LEN*MAC_C*43];
            8'd044: wgt_vec = wgt_reg[STEP_LEN*MAC_C*45-1:STEP_LEN*MAC_C*44];8'd045: wgt_vec = wgt_reg[STEP_LEN*MAC_C*46-1:STEP_LEN*MAC_C*45];
            8'd046: wgt_vec = wgt_reg[STEP_LEN*MAC_C*47-1:STEP_LEN*MAC_C*46];8'd047: wgt_vec = wgt_reg[STEP_LEN*MAC_C*48-1:STEP_LEN*MAC_C*47];
            8'd048: wgt_vec = wgt_reg[STEP_LEN*MAC_C*49-1:STEP_LEN*MAC_C*48];8'd049: wgt_vec = wgt_reg[STEP_LEN*MAC_C*50-1:STEP_LEN*MAC_C*49];
            8'd050: wgt_vec = wgt_reg[STEP_LEN*MAC_C*51-1:STEP_LEN*MAC_C*50];8'd051: wgt_vec = wgt_reg[STEP_LEN*MAC_C*52-1:STEP_LEN*MAC_C*51];
            8'd052: wgt_vec = wgt_reg[STEP_LEN*MAC_C*53-1:STEP_LEN*MAC_C*52];8'd053: wgt_vec = wgt_reg[STEP_LEN*MAC_C*54-1:STEP_LEN*MAC_C*53];
            8'd054: wgt_vec = wgt_reg[STEP_LEN*MAC_C*55-1:STEP_LEN*MAC_C*54];8'd055: wgt_vec = wgt_reg[STEP_LEN*MAC_C*56-1:STEP_LEN*MAC_C*55];
            8'd056: wgt_vec = wgt_reg[STEP_LEN*MAC_C*57-1:STEP_LEN*MAC_C*56];8'd057: wgt_vec = wgt_reg[STEP_LEN*MAC_C*58-1:STEP_LEN*MAC_C*57];
            8'd058: wgt_vec = wgt_reg[STEP_LEN*MAC_C*59-1:STEP_LEN*MAC_C*58];8'd059: wgt_vec = wgt_reg[STEP_LEN*MAC_C*60-1:STEP_LEN*MAC_C*59];
            8'd060: wgt_vec = wgt_reg[STEP_LEN*MAC_C*61-1:STEP_LEN*MAC_C*60];8'd061: wgt_vec = wgt_reg[STEP_LEN*MAC_C*62-1:STEP_LEN*MAC_C*61];
            8'd062: wgt_vec = wgt_reg[STEP_LEN*MAC_C*63-1:STEP_LEN*MAC_C*62];8'd063: wgt_vec = wgt_reg[STEP_LEN*MAC_C*64-1:STEP_LEN*MAC_C*63];
            default: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
        endcase
    end
endmodule


module SelectReg_128 #(parameter INWID = 4, parameter STEP_LEN=4, parameter MAC_C = 8)(
    input wire[INWID*4-1:0] wgt_reg[STEP_LEN*MAC_C*128-1:0],
    input wire[7:0] msk,
    output reg[INWID*4-1:0] wgt_vec[STEP_LEN*MAC_C-1:0]
);
    always_comb begin
        case(msk)
            8'd000: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];              8'd001: wgt_vec = wgt_reg[STEP_LEN*MAC_C*2-1:STEP_LEN*MAC_C*1];
            8'd002: wgt_vec = wgt_reg[STEP_LEN*MAC_C*3-1:STEP_LEN*MAC_C*2];8'd003: wgt_vec = wgt_reg[STEP_LEN*MAC_C*4-1:STEP_LEN*MAC_C*3];
            8'd004: wgt_vec = wgt_reg[STEP_LEN*MAC_C*5-1:STEP_LEN*MAC_C*4];8'd005: wgt_vec = wgt_reg[STEP_LEN*MAC_C*6-1:STEP_LEN*MAC_C*5];
            8'd006: wgt_vec = wgt_reg[STEP_LEN*MAC_C*7-1:STEP_LEN*MAC_C*6];8'd007: wgt_vec = wgt_reg[STEP_LEN*MAC_C*8-1:STEP_LEN*MAC_C*7];
            8'd008: wgt_vec = wgt_reg[STEP_LEN*MAC_C*9-1:STEP_LEN*MAC_C*8];8'd009: wgt_vec = wgt_reg[STEP_LEN*MAC_C*10-1:STEP_LEN*MAC_C*9];
            8'd010: wgt_vec = wgt_reg[STEP_LEN*MAC_C*11-1:STEP_LEN*MAC_C*10];8'd011: wgt_vec = wgt_reg[STEP_LEN*MAC_C*12-1:STEP_LEN*MAC_C*11];
            8'd012: wgt_vec = wgt_reg[STEP_LEN*MAC_C*13-1:STEP_LEN*MAC_C*12];8'd013: wgt_vec = wgt_reg[STEP_LEN*MAC_C*14-1:STEP_LEN*MAC_C*13];
            8'd014: wgt_vec = wgt_reg[STEP_LEN*MAC_C*15-1:STEP_LEN*MAC_C*14];8'd015: wgt_vec = wgt_reg[STEP_LEN*MAC_C*16-1:STEP_LEN*MAC_C*15];
            8'd016: wgt_vec = wgt_reg[STEP_LEN*MAC_C*17-1:STEP_LEN*MAC_C*16];8'd017: wgt_vec = wgt_reg[STEP_LEN*MAC_C*18-1:STEP_LEN*MAC_C*17];
            8'd018: wgt_vec = wgt_reg[STEP_LEN*MAC_C*19-1:STEP_LEN*MAC_C*18];8'd019: wgt_vec = wgt_reg[STEP_LEN*MAC_C*20-1:STEP_LEN*MAC_C*19];
            8'd020: wgt_vec = wgt_reg[STEP_LEN*MAC_C*21-1:STEP_LEN*MAC_C*20];8'd021: wgt_vec = wgt_reg[STEP_LEN*MAC_C*22-1:STEP_LEN*MAC_C*21];
            8'd022: wgt_vec = wgt_reg[STEP_LEN*MAC_C*23-1:STEP_LEN*MAC_C*22];8'd023: wgt_vec = wgt_reg[STEP_LEN*MAC_C*24-1:STEP_LEN*MAC_C*23];
            8'd024: wgt_vec = wgt_reg[STEP_LEN*MAC_C*25-1:STEP_LEN*MAC_C*24];8'd025: wgt_vec = wgt_reg[STEP_LEN*MAC_C*26-1:STEP_LEN*MAC_C*25];
            8'd026: wgt_vec = wgt_reg[STEP_LEN*MAC_C*27-1:STEP_LEN*MAC_C*26];8'd027: wgt_vec = wgt_reg[STEP_LEN*MAC_C*28-1:STEP_LEN*MAC_C*27];
            8'd028: wgt_vec = wgt_reg[STEP_LEN*MAC_C*29-1:STEP_LEN*MAC_C*28];8'd029: wgt_vec = wgt_reg[STEP_LEN*MAC_C*30-1:STEP_LEN*MAC_C*29];
            8'd030: wgt_vec = wgt_reg[STEP_LEN*MAC_C*31-1:STEP_LEN*MAC_C*30];8'd031: wgt_vec = wgt_reg[STEP_LEN*MAC_C*32-1:STEP_LEN*MAC_C*31];
            8'd032: wgt_vec = wgt_reg[STEP_LEN*MAC_C*33-1:STEP_LEN*MAC_C*32];8'd033: wgt_vec = wgt_reg[STEP_LEN*MAC_C*34-1:STEP_LEN*MAC_C*33];
            8'd034: wgt_vec = wgt_reg[STEP_LEN*MAC_C*35-1:STEP_LEN*MAC_C*34];8'd035: wgt_vec = wgt_reg[STEP_LEN*MAC_C*36-1:STEP_LEN*MAC_C*35];
            8'd036: wgt_vec = wgt_reg[STEP_LEN*MAC_C*37-1:STEP_LEN*MAC_C*36];8'd037: wgt_vec = wgt_reg[STEP_LEN*MAC_C*38-1:STEP_LEN*MAC_C*37];
            8'd038: wgt_vec = wgt_reg[STEP_LEN*MAC_C*39-1:STEP_LEN*MAC_C*38];8'd039: wgt_vec = wgt_reg[STEP_LEN*MAC_C*40-1:STEP_LEN*MAC_C*39];
            8'd040: wgt_vec = wgt_reg[STEP_LEN*MAC_C*41-1:STEP_LEN*MAC_C*40];8'd041: wgt_vec = wgt_reg[STEP_LEN*MAC_C*42-1:STEP_LEN*MAC_C*41];
            8'd042: wgt_vec = wgt_reg[STEP_LEN*MAC_C*43-1:STEP_LEN*MAC_C*42];8'd043: wgt_vec = wgt_reg[STEP_LEN*MAC_C*44-1:STEP_LEN*MAC_C*43];
            8'd044: wgt_vec = wgt_reg[STEP_LEN*MAC_C*45-1:STEP_LEN*MAC_C*44];8'd045: wgt_vec = wgt_reg[STEP_LEN*MAC_C*46-1:STEP_LEN*MAC_C*45];
            8'd046: wgt_vec = wgt_reg[STEP_LEN*MAC_C*47-1:STEP_LEN*MAC_C*46];8'd047: wgt_vec = wgt_reg[STEP_LEN*MAC_C*48-1:STEP_LEN*MAC_C*47];
            8'd048: wgt_vec = wgt_reg[STEP_LEN*MAC_C*49-1:STEP_LEN*MAC_C*48];8'd049: wgt_vec = wgt_reg[STEP_LEN*MAC_C*50-1:STEP_LEN*MAC_C*49];
            8'd050: wgt_vec = wgt_reg[STEP_LEN*MAC_C*51-1:STEP_LEN*MAC_C*50];8'd051: wgt_vec = wgt_reg[STEP_LEN*MAC_C*52-1:STEP_LEN*MAC_C*51];
            8'd052: wgt_vec = wgt_reg[STEP_LEN*MAC_C*53-1:STEP_LEN*MAC_C*52];8'd053: wgt_vec = wgt_reg[STEP_LEN*MAC_C*54-1:STEP_LEN*MAC_C*53];
            8'd054: wgt_vec = wgt_reg[STEP_LEN*MAC_C*55-1:STEP_LEN*MAC_C*54];8'd055: wgt_vec = wgt_reg[STEP_LEN*MAC_C*56-1:STEP_LEN*MAC_C*55];
            8'd056: wgt_vec = wgt_reg[STEP_LEN*MAC_C*57-1:STEP_LEN*MAC_C*56];8'd057: wgt_vec = wgt_reg[STEP_LEN*MAC_C*58-1:STEP_LEN*MAC_C*57];
            8'd058: wgt_vec = wgt_reg[STEP_LEN*MAC_C*59-1:STEP_LEN*MAC_C*58];8'd059: wgt_vec = wgt_reg[STEP_LEN*MAC_C*60-1:STEP_LEN*MAC_C*59];
            8'd060: wgt_vec = wgt_reg[STEP_LEN*MAC_C*61-1:STEP_LEN*MAC_C*60];8'd061: wgt_vec = wgt_reg[STEP_LEN*MAC_C*62-1:STEP_LEN*MAC_C*61];
            8'd062: wgt_vec = wgt_reg[STEP_LEN*MAC_C*63-1:STEP_LEN*MAC_C*62];8'd063: wgt_vec = wgt_reg[STEP_LEN*MAC_C*64-1:STEP_LEN*MAC_C*63];
            8'd064: wgt_vec = wgt_reg[STEP_LEN*MAC_C*65-1:STEP_LEN*MAC_C*64];8'd065: wgt_vec = wgt_reg[STEP_LEN*MAC_C*66-1:STEP_LEN*MAC_C*65];
            8'd066: wgt_vec = wgt_reg[STEP_LEN*MAC_C*67-1:STEP_LEN*MAC_C*66];8'd067: wgt_vec = wgt_reg[STEP_LEN*MAC_C*68-1:STEP_LEN*MAC_C*67];
            8'd068: wgt_vec = wgt_reg[STEP_LEN*MAC_C*69-1:STEP_LEN*MAC_C*68];8'd069: wgt_vec = wgt_reg[STEP_LEN*MAC_C*70-1:STEP_LEN*MAC_C*69];
            8'd070: wgt_vec = wgt_reg[STEP_LEN*MAC_C*71-1:STEP_LEN*MAC_C*70];8'd071: wgt_vec = wgt_reg[STEP_LEN*MAC_C*72-1:STEP_LEN*MAC_C*71];
            8'd072: wgt_vec = wgt_reg[STEP_LEN*MAC_C*73-1:STEP_LEN*MAC_C*72];8'd073: wgt_vec = wgt_reg[STEP_LEN*MAC_C*74-1:STEP_LEN*MAC_C*73];
            8'd074: wgt_vec = wgt_reg[STEP_LEN*MAC_C*75-1:STEP_LEN*MAC_C*74];8'd075: wgt_vec = wgt_reg[STEP_LEN*MAC_C*76-1:STEP_LEN*MAC_C*75];
            8'd076: wgt_vec = wgt_reg[STEP_LEN*MAC_C*77-1:STEP_LEN*MAC_C*76];8'd077: wgt_vec = wgt_reg[STEP_LEN*MAC_C*78-1:STEP_LEN*MAC_C*77];
            8'd078: wgt_vec = wgt_reg[STEP_LEN*MAC_C*79-1:STEP_LEN*MAC_C*78];8'd079: wgt_vec = wgt_reg[STEP_LEN*MAC_C*80-1:STEP_LEN*MAC_C*79];
            8'd080: wgt_vec = wgt_reg[STEP_LEN*MAC_C*81-1:STEP_LEN*MAC_C*80];8'd081: wgt_vec = wgt_reg[STEP_LEN*MAC_C*82-1:STEP_LEN*MAC_C*81];
            8'd082: wgt_vec = wgt_reg[STEP_LEN*MAC_C*83-1:STEP_LEN*MAC_C*82];8'd083: wgt_vec = wgt_reg[STEP_LEN*MAC_C*84-1:STEP_LEN*MAC_C*83];
            8'd084: wgt_vec = wgt_reg[STEP_LEN*MAC_C*85-1:STEP_LEN*MAC_C*84];8'd085: wgt_vec = wgt_reg[STEP_LEN*MAC_C*86-1:STEP_LEN*MAC_C*85];
            8'd086: wgt_vec = wgt_reg[STEP_LEN*MAC_C*87-1:STEP_LEN*MAC_C*86];8'd087: wgt_vec = wgt_reg[STEP_LEN*MAC_C*88-1:STEP_LEN*MAC_C*87];
            8'd088: wgt_vec = wgt_reg[STEP_LEN*MAC_C*89-1:STEP_LEN*MAC_C*88];8'd089: wgt_vec = wgt_reg[STEP_LEN*MAC_C*90-1:STEP_LEN*MAC_C*89];
            8'd090: wgt_vec = wgt_reg[STEP_LEN*MAC_C*91-1:STEP_LEN*MAC_C*90];8'd091: wgt_vec = wgt_reg[STEP_LEN*MAC_C*92-1:STEP_LEN*MAC_C*91];
            8'd092: wgt_vec = wgt_reg[STEP_LEN*MAC_C*93-1:STEP_LEN*MAC_C*92];8'd093: wgt_vec = wgt_reg[STEP_LEN*MAC_C*94-1:STEP_LEN*MAC_C*93];
            8'd094: wgt_vec = wgt_reg[STEP_LEN*MAC_C*95-1:STEP_LEN*MAC_C*94];8'd095: wgt_vec = wgt_reg[STEP_LEN*MAC_C*96-1:STEP_LEN*MAC_C*95];
            8'd096: wgt_vec = wgt_reg[STEP_LEN*MAC_C*97-1:STEP_LEN*MAC_C*96];8'd097: wgt_vec = wgt_reg[STEP_LEN*MAC_C*98-1:STEP_LEN*MAC_C*97];
            8'd098: wgt_vec = wgt_reg[STEP_LEN*MAC_C*99-1:STEP_LEN*MAC_C*98];8'd099: wgt_vec = wgt_reg[STEP_LEN*MAC_C*100-1:STEP_LEN*MAC_C*99];
            8'd100: wgt_vec = wgt_reg[STEP_LEN*MAC_C*101-1:STEP_LEN*MAC_C*100];8'd101: wgt_vec = wgt_reg[STEP_LEN*MAC_C*102-1:STEP_LEN*MAC_C*101];
            8'd102: wgt_vec = wgt_reg[STEP_LEN*MAC_C*103-1:STEP_LEN*MAC_C*102];8'd103: wgt_vec = wgt_reg[STEP_LEN*MAC_C*104-1:STEP_LEN*MAC_C*103];
            8'd104: wgt_vec = wgt_reg[STEP_LEN*MAC_C*105-1:STEP_LEN*MAC_C*104];8'd105: wgt_vec = wgt_reg[STEP_LEN*MAC_C*106-1:STEP_LEN*MAC_C*105];
            8'd106: wgt_vec = wgt_reg[STEP_LEN*MAC_C*107-1:STEP_LEN*MAC_C*106];8'd107: wgt_vec = wgt_reg[STEP_LEN*MAC_C*108-1:STEP_LEN*MAC_C*107];
            8'd108: wgt_vec = wgt_reg[STEP_LEN*MAC_C*109-1:STEP_LEN*MAC_C*108];8'd109: wgt_vec = wgt_reg[STEP_LEN*MAC_C*110-1:STEP_LEN*MAC_C*109];
            8'd110: wgt_vec = wgt_reg[STEP_LEN*MAC_C*111-1:STEP_LEN*MAC_C*110];8'd111: wgt_vec = wgt_reg[STEP_LEN*MAC_C*112-1:STEP_LEN*MAC_C*111];
            8'd112: wgt_vec = wgt_reg[STEP_LEN*MAC_C*113-1:STEP_LEN*MAC_C*112];8'd113: wgt_vec = wgt_reg[STEP_LEN*MAC_C*114-1:STEP_LEN*MAC_C*113];
            8'd114: wgt_vec = wgt_reg[STEP_LEN*MAC_C*115-1:STEP_LEN*MAC_C*114];8'd115: wgt_vec = wgt_reg[STEP_LEN*MAC_C*116-1:STEP_LEN*MAC_C*115];
            8'd116: wgt_vec = wgt_reg[STEP_LEN*MAC_C*117-1:STEP_LEN*MAC_C*116];8'd117: wgt_vec = wgt_reg[STEP_LEN*MAC_C*118-1:STEP_LEN*MAC_C*117];
            8'd118: wgt_vec = wgt_reg[STEP_LEN*MAC_C*119-1:STEP_LEN*MAC_C*118];8'd119: wgt_vec = wgt_reg[STEP_LEN*MAC_C*120-1:STEP_LEN*MAC_C*119];
            8'd120: wgt_vec = wgt_reg[STEP_LEN*MAC_C*121-1:STEP_LEN*MAC_C*120];8'd121: wgt_vec = wgt_reg[STEP_LEN*MAC_C*122-1:STEP_LEN*MAC_C*121];
            8'd122: wgt_vec = wgt_reg[STEP_LEN*MAC_C*123-1:STEP_LEN*MAC_C*122];8'd123: wgt_vec = wgt_reg[STEP_LEN*MAC_C*124-1:STEP_LEN*MAC_C*123];
            8'd124: wgt_vec = wgt_reg[STEP_LEN*MAC_C*125-1:STEP_LEN*MAC_C*124];8'd125: wgt_vec = wgt_reg[STEP_LEN*MAC_C*126-1:STEP_LEN*MAC_C*125];
            8'd126: wgt_vec = wgt_reg[STEP_LEN*MAC_C*127-1:STEP_LEN*MAC_C*126];8'd127: wgt_vec = wgt_reg[STEP_LEN*MAC_C*128-1:STEP_LEN*MAC_C*127];
            default: wgt_vec = wgt_reg[STEP_LEN*MAC_C-1:0];
        endcase
    end
endmodule


module broadcast_tb;
    
    // Parameters
    parameter OUT_BIT = 32;
    parameter LANE_NUM = 8;
    parameter LOW_PRE = 0;
    parameter INWID = 4;
    parameter STEP_LEN = 4;
    parameter MAC_C = 8;
    parameter MAC_R = 32;
    // Clock period
    parameter CLK_PERIOD = 20;

    // Signals
    logic clk;
    logic reset;
    logic [INWID*4-1:0]wgt_reg[STEP_LEN*MAC_C-1:0];
    logic [INWID*4-1:0]act_reg[STEP_LEN*MAC_R-1:0];
    logic [INWID*4-1:0]wgt_arr[STEP_LEN*MAC_R*MAC_C-1:0];
    logic [INWID*4-1:0]act_arr[STEP_LEN*MAC_R*MAC_C-1:0];


    Broadcast #(
        .LOW_PRE(LOW_PRE),
        .INWID(INWID),
        .STEP_LEN(STEP_LEN),  
        .MAC_R(MAC_R),
        .MAC_C(MAC_C)
    ) dut(
        .wgt_reg(wgt_reg),.act_reg(act_reg),
        .wgt_arr(wgt_arr),.act_arr(act_arr)
    );
    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        #20;
        reset = 1;
    end

    // Test stimuli
    initial begin
        #50
        repeat(20) begin

        foreach (wgt_reg[i]) wgt_reg[i] = $urandom_range(0,65536);
        foreach (act_reg[i]) act_reg[i] = $urandom_range(0,65536);

        // Wait for computation
        #20;

        // Verify output
        // Add code to compare the output with expected values

        // Finish simulation
        end
        $finish;
    end
endmodule


module unicast_tb;
    
    // Parameters
    parameter OUT_BIT = 32;
    parameter LANE_NUM = 8;
    parameter LOW_PRE = 0;
    parameter INWID = 4;
    parameter MAC_O = 4;
    parameter MAC_C = 8;
    parameter MAC_R = 32;
    // Clock period
    parameter STEP_LEN = 4;
    parameter CLK_PERIOD = 20;
    parameter TILE = 8;
    // Signals
    logic clk;
    logic reset;
    logic [INWID*4-1:0]wgt_reg[STEP_LEN*MAC_C*TILE-1:0];
    logic [INWID*4-1:0]act_reg[STEP_LEN*MAC_R*MAC_C-1:0];
    logic [INWID*4-1:0]wgt_arr[STEP_LEN*MAC_R*MAC_C-1:0];
    logic [INWID*4-1:0]act_arr[STEP_LEN*MAC_R*MAC_C-1:0];
    logic [7:0] msk[MAC_R-1:0];


    Unicast #(
        .INWID(INWID),
        .STEP_LEN(STEP_LEN),  
        .MAC_R(MAC_R),
        .MAC_C(MAC_C),
        .TILE(TILE)
    ) dut(
        .wgt_reg(wgt_reg),.act_reg(act_reg),
        .msk(msk),
        .wgt_arr(wgt_arr),.act_arr(act_arr)
    );
    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        #20;
        reset = 1;
    end

    // Test stimuli
    initial begin
        #50
        repeat(20) begin

        foreach (wgt_reg[i]) wgt_reg[i] = $urandom_range(0,65536);
        foreach (act_reg[i]) act_reg[i] = $urandom_range(0,65536);
        foreach (msk[i]) msk[i] = $urandom_range(0,127);
        // Wait for computation
        #20;

        // Verify output
        // Add code to compare the output with expected values

        // Finish simulation
        end
        $finish;
    end
endmodule