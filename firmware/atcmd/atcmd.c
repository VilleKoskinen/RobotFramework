#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdbool.h>
#include "pico/stdlib.h"

#define LINE_SIZE  80

//#define SIMPLE_AT
#define LOCAL_ECHO_AT

#ifdef SIMPLE_AT
bool local_echo = false;
#else
bool local_echo = true;
#endif


void parse_cmd(char *cmd);

int main() {

    // Initialize chosen serial port
    stdio_init_all();
    //stdio_set_translate_crlf(&stdio_usb, false); // disable cr-lf translation

    char rcv[LINE_SIZE] = {0};
    int pos = 0;
    while(true){
        int ch = getchar_timeout_us(5000000);
        if(ch != PICO_ERROR_TIMEOUT) {
            if(local_echo) putchar(ch);
            //printf("%02X ",ch);
            if(ch == '\r' || ch == '\n') {
                // crude command parser
                if(strlen(rcv) > 0) {
                    //printf("\n[%s]\n",rcv);
                    parse_cmd(rcv);
                }
                // clear
                rcv[0] = '\0';
                pos = 0;
            }
            else {
                if(ch == 127) { /* backspace handling */
                    if(pos > 0) {
                        --pos;
                    }
                }
                else {
                    //if(isspace(ch)) ch = ' '; // convert all white space to spaces
                    rcv[pos++] = ch;
                    if(pos >= LINE_SIZE) --pos;
                }
                rcv[pos] = '\0';
            }
        }
        else {
            // timeout
            //rcv[0] =  '\0';
            //pos = 0;
        }
    }
}

#ifdef SIMPLE_AT
void parse_cmd(char *cmd) {
    if(strncmp(cmd, "AT", 2) == 0 || strncmp(cmd, "at", 2) == 0) {
        char *par = cmd + 2;
        if(par[0] == '\0') {
            printf("OK\n");
        }
        else if(strncmp("+SEND=\"", par, 7) == 0 && strchr(par + 7, '\"') != NULL) {
            par += 7;
            par[strcspn(par, "\"")] = '\0';
            printf("SENT=\"");
            for(int i = 0; par[i] != '\0'; ++i) {
                putchar(isalnum((int)par[i]) ? toupper((int)par[i]) : (isspace((int)par[i]) ? ' ' : 'X'));
            }
            printf("\"\nOK\n");
        }
        else {
            printf("INVALID\n");
            //printf("AT: %s\n", par);
        }
    }
    else {
        printf("ERROR\n");
    }
}
#endif

#ifdef LOCAL_ECHO_AT
void parse_cmd(char *cmd) {
    if(strncmp(cmd, "AT", 2) == 0 || strncmp(cmd, "at", 2) == 0) {
        char *par = cmd + 2;
        int echo = 0;
        switch(par[0]) {
            case 0:
                printf("OK\n");
                break;
            case 'E':
            case 'e':
                if(sscanf(par+1, "%d", &echo)==1) {
                    local_echo = (bool) echo;
                    printf("OK\n");
                }
                else if(par[1] == '\0') {
                    printf("%s\nOK\n", local_echo ? "ON" : "OFF");
                }
                else {
                    printf("INVALID\n");
                }
                break;
            default:
                if(strncmp("+SEND=\"", par, 7) == 0 && strchr(par + 7, '\"') != NULL) {
                    par += 7;
                    printf("SENT=\"");
                    for(int i = 0; par[i] != '\0' && par[i] != '\"'; ++i) {
                        putchar(isalnum((int)par[i]) ? toupper((int)par[i]) : (isspace((int)par[i]) ? ' ' : 'X'));
                    }
                    printf("\"\nOK\n");
                }
                else {
                    printf("INVALID\n");
                }
                break;
        }
    }
    else {
        printf("ERROR\n");
    }
}
#endif
