*** Settings ***
Documentation     Example of morse transmitter test
...
...               Change this example to use data driven style 
...               Test with different texts and speeds
Suite Setup			Suite setup
Suite Teardown		Suite teardown
Test Template		Send text to Pico
Resource			AtCommandLibrary.resource

*** Variables ***
${COM_PORT}         /dev/tty.usbmodem1101

*** Test Cases ***              Input               Expected Response
Connection Test                 AT                  AT
Only Letters                    this is a test      THIS IS A TEST
Only Numbers                    1234567890          1234567890
Mixed Letters and Numbers       test123test         TEST123TEST
Whitespace and Tabs             this${SPACE}is${SPACE}a${SPACE}test    THIS IS A TEST
Special Characters              hello, world!       HELLOX WORLDX