
/*
Configuration for the code below:

Connect portA to J1 Port of DC Motor Module
Jumpers of portA are : 5V, pull up ( top one to left, other to left)

Connect portE to J1 Port of Push Button Module
Jumpers of portE are : 3.3V, pull up( top one to right, other to left)

*/
void main() {

  AD1PCFG = 0xFFFF;
  DDPCON.JTAGEN = 0; // disable JTAG

  TRISA = 0x0000;  //portA is output to turn on motor.
  TRISE = 0xFFFF;  //portE is inputs to read push-buttons.

  //LATA = 0xFFFF;
  //LATE = 0x0000;

  while(1)
  {
    if(PORTE.RA0 == 1 && PORTE.RA1 == 1)
    {
     PORTA = 0x00;
    }
    else if(PORTE.RA0 == 1)
    {
     PORTA = 0x04;
    }
    else if(PORTE.RA1 == 1)
    {
     PORTA = 0x02;
    }
    else
    {
     PORTA = 0x00;
    }
  }
}

------------------------------------------------------------------------------------------
/*
Configuration for the code below:

Connect portA to J1 Port of 4 Digit Seven Segment Module
Jumpers of portA are : 5V, pull down ( top one to left, other to right )

Connect portE to J2 Port of 4 Digit Seven Segment Module
Jumpers of portE are : 5V, pull down ( top one to left, other to right )

*/

void displayStartingFromNumber(int a);

unsigned char binary_pattern[]={0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};
unsigned char port_values[]={0x01,0x02,0x04,0x08}; // determining which digit will be displayed
int i;
int x;
int j;
int numbers[4];
void main() {

    AD1PCFG = 0xFFFF;      // Configure AN pins as digital I/O
    JTAGEN_bit = 0;        // Disable JTAG

    TRISA = 0x00;          //portA is output to D
    TRISE = 0X00;         //portE is output to AN

    j = 1;                // start from 1
    //loop forever
    while(1)
    {
        displayStartingFromNumber(j);
        if(j >= 10) // if the number is over 9, return to 1. So after 9123, go to 1234
        {
            j = 0;
        }
        j++;
    }
}//main

void displayStartingFromNumber(int a) {
    x = a;
    numbers[4];                 // will hold the digit values to be displayed simultaneously

    /* fills the array to determine what digits will be displayed
    Example: 1234, 7891 */
    for(i = 0; i < 4; i++)
    {
        if(x >= 10)         // when the number is over 9, return to 1
        {
            x = 1;
        }
        numbers[i] = x;
        x = x + 1;
    }

    /* displays the digits simultaneously by displaying each digit for 1 ms
    since each digit will be displayed for 1 ms, when this is looped for
    1000 times, the digits will be displayed for total of one second.*/
    for(i = 0; i < 1000; i++) {
        // display the number
            PORTA = binary_pattern[numbers[i%4]];   // set the number to be displayed
            PORTE = port_values[i%4];               // set which digit will display the number
            Delay_ms(1);                            // display that digit for 1 ms
    }
}
