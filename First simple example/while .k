module WHILE-SYNTAX

  syntax AExp ::= Int
                | Id
                | AExp "/" AExp               [left, seqstrict]
                > AExp "+" AExp               [left, seqstrict]
                | "-" AExp [strict]
                | "(" AExp ")" [bracket]

  syntax BExp ::= Bool
                 | AExp "<" AExp              [seqstrict]
                 | "!" BExp                   [strict]
                 > BExp "&&" BExp             [left, strict(1)]
                 | "(" BExp ")"               [bracket]

  syntax Stmt ::= "skip"
                 | Id "=" AExp                [strict(2)]
                 | "if" BExp "then" Stmt
                             "else" Stmt      [strict(1)]
                 | "while" BExp "do" Stmt
                 > Stmt ";" Stmt              [left]
                 | "(" Stmt ")"               [bracket]

endmodule

module WHILE
  imports WHILE-SYNTAX

  syntax KResult ::= Int | Bool

  configuration <T>
                  <k color="red"> $PGM:Stmt </k>
                  <state color="yellow"> String2Id("x"):Id |-> 3 String2Id("y"):Id |-> 4 </state>
                </T>

// AExp
  rule <k> X:Id => I ... </k> <state>... X |-> I ...</state>
  rule I:Int / J:Int => I /Int J
  rule I:Int + J:Int => I +Int J
  rule - I:Int => 0 -Int I

// BExp
  rule I1 < I2 => I1 <Int I2
  rule ! T => notBool T
  rule true && B => B
  rule false && _ => false

// Stmt
  rule skip => . [structural]
  rule <k> X = I:Int => . ...</k> <state> M:Map => M X|->I </state> when notBool (X in keys(M))
  rule <k> X = I:Int => . ...</k> <state>... X |-> (_ => I) ...</state>
  rule S1:Stmt ; S2:Stmt => S1 ~> S2  [structural]
  rule if true then S:Stmt else _ => S
  rule if false then _ else S => S
  rule while B  do S => if B then ( S ; while B do S ) else skip [structural]

endmodule

