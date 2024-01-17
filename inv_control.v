module inv_control #(
   parameter WIDTH = 256   //sua
) (
  // Global
  input                     clk,
  input                     reset_n,
  
  // Input
  input wire [WIDTH:0]      u,
  input wire [WIDTH:0]      v,
  input wire [WIDTH:0]      r,
  input wire [WIDTH:0]      s,
  input wire [WIDTH-1:0]    P,
  input wire [WIDTH-1:0]    nu_in,
  
  input wire                start_inv,
  
  input wire [WIDTH:0]	    denta_result,
  
  input wire                done_denta,
  input wire                done_sigma,

  // Output
  output reg [WIDTH:0]      u_cal,
  output reg [WIDTH:0]      v_cal,
  output reg [WIDTH:0]      r_cal,
  output reg [WIDTH:0]      s_cal,
  
  output reg [1:0]          sel_u,
  output reg [1:0]          sel_v,
  output reg [1:0]          sel_r,
  output reg [1:0]          sel_s,
  output reg [2:0]          sel_denta,
  output reg [1:0]          sel_sigma,
  
  output reg                start_denta,
  output reg                start_sigma,

  output reg                done_inv,
  output reg [WIDTH:0]      inv
);

  // local declarations

  parameter [12:0] IDLE        = 13'b00000000000001;
  parameter [12:0] LOAD        = 13'b00000000000010;
  parameter [12:0] CHECK       = 13'b00000000000100;
  parameter [12:0] P1          = 13'b00000000001000;
  parameter [12:0] P2          = 13'b00000000010000;
  parameter [12:0] P3          = 13'b00000000100000;
  parameter [12:0] P4          = 13'b00000001000000;
  parameter [12:0] P5          = 13'b00000010000000;
  parameter [12:0] P6          = 13'b00000100000000;
  parameter [12:0] P7          = 13'b00001000000000;
  parameter [12:0] CALSIGMA    = 13'b00010000000000;
  parameter [12:0] CALUVRS     = 13'b00100000000000;
  parameter [12:0] STORE       = 13'b01000000000000;
  parameter [12:0] DONE        = 13'b10000000000000;


  //wire [WIDTH - 2:0] PRIME    = 256'd115792089237316195423570985008687907853269984665640564039457584007908834671663;
  //wire [WIDTH - 2:0] ADJUST_M = 256'd4294968273;     // do not change
  reg [12:0] state;
  reg [12:0] n_state;
  reg [12:0] pre_state;
  
  reg [10:0]  pi0;

  reg         sel;
  wire        uv_gt;
  // Conbinational Logic
   compare_256bit (.a(u), .b(v), .eq(), .gt(uv_gt), .lt());
	
   always @(*) begin
      case(state)
         IDLE: begin
            n_state = start_inv ? LOAD : IDLE;
         end
         LOAD: begin
            n_state = CHECK;
         end
         CHECK: begin
            n_state = pi0 < 'd512 ? P1 : DONE;
         end
         P1: begin
            if(v > 'd0) begin
              if(u[0] == 'b0) begin
                 n_state = P2;
              end
              else begin
                 if(v[0] == 'b0) begin
                    n_state = P3;
                 end
                 else begin
                    if(uv_gt) begin
                       n_state = P4;
                    end
                    else begin
                       n_state = P5;
                    end
                 end
              end
           end 
           else begin
              if(r > P) begin
                 n_state = P6;
              end
              else begin
                 n_state = P7;
              end
           end
        end
        P2: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P2;
           end
        end
        P3: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P3;
           end
        end
        P4: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P4;
           end
        end
        P5: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P5;
           end
        end
        P6: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P6;
           end
        end
        P7: begin
           if(done_denta) begin
              n_state = CALSIGMA;
           end
           else begin
              n_state = P7;
           end
        end
        CALSIGMA: begin
           n_state = done_sigma ? CALUVRS : CALSIGMA;
        end
        CALUVRS: begin
           n_state = STORE;
        end
        STORE: begin
           n_state = CHECK;
        end
        DONE: begin
           n_state = done_denta ? IDLE : DONE;
        end
        default: begin
           n_state = IDLE;
        end
     endcase
  end

  // State Register

  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        state <= IDLE;
     end
	  else if (!start_inv) begin
		  state <= IDLE;	
	  end
     else begin
        state <= n_state;
     end
  end

 always @(posedge clk or negedge reset_n) begin
      if(!reset_n) begin
         sel <= 1'b0;
      end
      else begin
         sel <= (pi0 == 0 && state != STORE) ? 1'b1 : 1'b0;
      end
  end
  
  // Output Logic
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        pi0            <= 'd0;
        u_cal          <= 'd0;
        v_cal          <= 'd0;
        r_cal          <= 'd0;
        s_cal          <= 'd0;
        sel_u          <= 'd0;
        sel_v          <= 'd0;
        sel_r          <= 'd0;
        sel_s          <= 'd0;
        start_denta    <= 'd0;
        start_sigma    <= 'd0;
        done_inv       <= 'd0;
//        inv_nu         <= 'd0;
        sel_denta      <= 'd0;
        sel_sigma      <= 'd0; 
        pre_state      <= IDLE;
		  inv            <= 'd0;
     end
     else begin
        case(state)
           IDLE: begin
              pi0                <= 'd0;
              u_cal              <= 'd0;
              v_cal              <= 'd0;
              r_cal              <= 'd0;
              s_cal              <= 'd0;
              sel_u              <= 'd0;
              sel_v              <= 'd0;
              sel_r              <= 'd0;
              sel_s              <= 'd0;
              start_denta        <= 'd0;
              start_sigma        <= 'd0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;				  
              sel_denta          <= 'd0;
              sel_sigma          <= 'd0; 
              pre_state          <= IDLE;
				  inv                <= 'd0;
           end
           LOAD: begin
              pi0                <= pi0;
				  u_cal              <= sel ? {1'b0,P} : u;
              v_cal              <= sel ? {1'b0,nu_in} : v;
              r_cal              <= sel ? 'd0 : r;
              s_cal              <= sel ? 'd1 : s;
              sel_u              <= 'd0;
              sel_v              <= 'd0;
              sel_r              <= 'd0;  
              sel_s              <= 'd0;
              start_denta        <= 'd0;
              start_sigma        <= 'd0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 'd0;
              sel_sigma          <= 'd0;
              pre_state          <= pre_state;
				  inv                <= 'd0;
           end
           CHECK: begin
              pi0                <= pi0;
				  u_cal              <= sel ? {1'b0,P} : u;
              v_cal              <= sel ? {1'b0,nu_in} : v;
              r_cal              <= sel ? 'd0 : r;
              s_cal              <= sel ? 'd1 : s;
              sel_u              <= 'd0;
              sel_v              <= 'd0;
              sel_r              <= 'd0;  
              sel_s              <= 'd0;
              start_denta        <= 'd0;
              start_sigma        <= 'd0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
				  sel_denta          <= 'd0;
              sel_sigma          <= 'd0;
              pre_state          <= pre_state;
				  inv                <= 'd0;
           end
           P1: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;
              start_denta        <= 'd0;
              start_sigma        <= 'd0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= sel_denta;
              sel_sigma          <= 'd0;
              pre_state          <= pre_state;
				  inv                <= 'd0;
           end
           P2: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;
				  start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b000;   // r -s
              sel_sigma          <= 2'b00;    //denta + s
              pre_state          <= P2;
				  inv                <= 'd0;
           end
           P3: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;    
              start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b001;  // s - r
              sel_sigma          <= 2'b01;   // denta + r
              pre_state          <= P3;
				  inv                <= 'd0;
           end
           P4: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;
              start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b010;  // u - v
              sel_sigma          <= 2'b10;   // r + s
              pre_state          <= P4;
				  inv                <= 'd0;
           end
           P5: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;    
              start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b011;  // v - u
              sel_sigma          <= 2'b10;   // r + s
              pre_state          <= P5;
				  inv                <= 'd0;
           end
           P6: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;   
              start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b100;  // r - p
              sel_sigma          <= 2'b11;   // s + p
              pre_state          <= P6;
				  inv                <= 'd0;
           end
           P7: begin
              pi0                <= pi0;
				  u_cal 					<= u_cal;
              v_cal 					<= v_cal;
              r_cal 					<= r_cal;
              s_cal 					<= s_cal;
              sel_u              <= sel_u;
              sel_v              <= sel_v;
              sel_r              <= sel_r;
              sel_s              <= sel_s;   
              start_denta        <= 'b1;
              start_sigma        <= (done_denta) ? 1'b1 : 1'b0;
              done_inv           <= 'd0;
//              inv_nu             <= 256'd0;
              sel_denta          <= 3'b100;  // r - p
              sel_sigma          <= 2'b11;   // s + p
              pre_state          <= P7;
				  inv                <= 'd0;
           end
           CALSIGMA: begin
              pi0              <= pi0;
              u_cal            <= u_cal;
              v_cal            <= v_cal;
              r_cal            <= r_cal;
              s_cal            <= s_cal;
              sel_u            <= sel_u;
              sel_v            <= sel_v;
              sel_r            <= sel_r;
              sel_s            <= sel_s;
              start_denta      <= 'd0;
              start_sigma      <= 'd1;
              done_inv         <= 'd0;
//              inv_nu           <= 256'd0;
              sel_denta        <= sel_denta;
              sel_sigma        <= sel_sigma;
              pre_state        <= pre_state;
				  inv              <= 'd0;
           end
           CALUVRS: begin
              pi0              <= pi0;
              u_cal            <= u_cal;
              v_cal            <= v_cal;
              r_cal            <= r_cal;
              s_cal            <= s_cal;
              case(pre_state)
                 P2: begin
                    sel_u              <= 2'b01;       // u / 2 
                    sel_v              <= 2'b00;       // giu nguyen
                    sel_r              <= 2'b10;       // sigma
                    sel_s              <= 2'b01;       // 2 * s
                 end 
                 P3: begin
                    sel_u              <= 2'b00;       // giu nguyen
                    sel_v              <= 2'b01;       // v / 2
                    sel_r              <= 2'b01;       // 2 * r
                    sel_s              <= 2'b10;       // sigma
                 end
                 P4: begin
                    sel_u              <= 2'b10;       // denta / 2
                    sel_v              <= 2'b00;       // giu nguyen
                    sel_r              <= 2'b10;       // sigma
                    sel_s              <= 2'b01;       // 2 * s 
                 end
                 P5: begin
					     sel_u              <= 2'b00;       // giu nguyen
                    sel_v              <= 2'b10;       // denta / 2
						  sel_r              <= 2'b01;       // 2 * r  
                    sel_s              <= 2'b10;       // sigma
                 end
                 P6: begin
                    sel_u              <= 2'b00;       // giu nguyen
                    sel_v              <= 2'b00;       // giu nguyen 
                    sel_r              <= 2'b11;       // 2 * denta
                    sel_s              <= 2'b11;       // sigma / 2   
                 end
                 P7: begin
                    sel_u              <= 2'b00;       // giu nguyen
                    sel_v              <= 2'b00;       // giu nguyen
                    sel_r              <= 2'b01;       // 2 * r
                    sel_s              <= 2'b11;       // sigma / 2
                 end
                 default: begin
                    sel_u              <= sel_u;
                    sel_v              <= sel_v;
                    sel_r              <= sel_r;
                    sel_s              <= sel_s;
                    
                 end
              endcase
              start_denta      <= 'd0;
              start_sigma      <= 'd0;
              done_inv         <= 'd0;
//              inv_nu           <= 256'd0;
              sel_denta        <= sel_denta;
              sel_sigma        <= sel_sigma;
              pre_state        <= pre_state;
				  inv              <= 'd0;
           end
           STORE: begin
              pi0              <= pi0 + 11'd1;
              u_cal            <= u_cal;
              v_cal            <= v_cal;
              r_cal            <= r_cal;
              s_cal            <= s_cal;
              sel_u            <= sel_u;
              sel_v            <= sel_v;
              sel_r            <= sel_r;
              sel_s            <= sel_s;
				  start_denta      <= 'd0;
              start_sigma      <= 'd0;
              done_inv         <= 'd0;
//              inv_nu           <= 256'd0;
              sel_denta        <= sel_denta;
              sel_sigma        <= sel_sigma;
              pre_state        <= IDLE;
				  inv              <= 'd0;
           end
           DONE: begin
              pi0              <= pi0;
              u_cal            <= u_cal;
              v_cal            <= v_cal;
              r_cal            <= r_cal;
              s_cal            <= s_cal;
              sel_u            <= sel_u;
              sel_v            <= sel_v;
              sel_r            <= sel_r;
              sel_s            <= sel_s;
              start_denta      <= 'b1;
              start_sigma      <= 'd0;
              done_inv         <= (done_denta) ? 1'b1 : 1'b0;
//              inv_nu           <= r[255:0];
              sel_denta        <= (r > 0) ? 3'b110  : 3'b101;
              sel_sigma        <= sel_sigma;
              pre_state        <= IDLE;
				  inv              <= (done_denta) ? denta_result : 'd0;
           end
           default: begin
              pi0              <= 'd0;
              u_cal            <= 'd0;
              v_cal            <= 'd0;
              r_cal            <= 'd0;
              s_cal            <= 'd0;
              sel_u            <= 'd0;
              sel_v            <= 'd0;
              sel_r            <= 'd0;
              sel_s            <= 'd0;
				  start_denta      <= 'd0;
              start_sigma      <= 'd0;
              done_inv         <= 'd0;
//              inv_nu           <= 256'd0;
              sel_denta        <= 'd0;
              sel_sigma        <= 'd0;
              pre_state        <= IDLE;
				  inv              <= 'd0;
           end
        endcase
     end
  end
endmodule