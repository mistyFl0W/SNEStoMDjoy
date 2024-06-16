# SNEStoMDjoy
Super Famicom/Super Nintendo/SNES controller to Megadrive/Genesis converter. Using Arduino Nano (Atmega328p).  
Holding down Select button enables 3-button mode.

## SNES controller pinout:
<pre>
 ______________________________________
|                     |                 \
| (1)  (2)  (3)  (4)  |  (5)  (6)  (7)   )
|_____________________|________________ /
</pre>

|Pin | Function | Wire color|
|----|----------|-----------|
|1   |+5V       |White      |
|2   |Clock     |Yellow     |
|3   |Latch     |Orange     |
|4   |Data      |Red        |
|5   | -        |no wire    |
|6   | -        |no wire    |
|7   |Gnd       |Brown      |

**Connection to MCU:**
| SNES    | Atmega Pin |
|---------|------------|
|2 (Clock)| PC0        |
|3 (Latch)| PC1        |
|4 (Data) | PC2        |


## Mega Drive controller pinout (front of console):
<pre>
 ___________________________
\                           /
 \   (1) (2) (3) (4) (5)   /
  \    (6) (7) (8) (9)    /
   \ ___________________ /
</pre>

|Pin | Function | Wire color|
|----|----------|-----------|
|1   |Up        |Brown      |
|2   |Down      |Red        |
|3   |Left      |Orange     |
|4   |Right     |Yellow     |
|5   |+5V       |Green      |
|6   |A/B       |Blue       |
|7   |Select    |Grey       |
|8   |GND       |Black      |
|9   |Start/C   |White      |

**Connection to MCU:**
| MD        | Atmega Pin |
|-----------|------------|
|1 (Up)     |PD2         |
|2 (Down)   |PD3         |
|3 (Left)   |PD4         |
|4 (Right)  |PD5         |
|6 (A/B)    |PD6         |
|7 (Select) |PB0         |
|9 (Start/C)|PD7         |
