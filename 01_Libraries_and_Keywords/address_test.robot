*** Settings ***
Library    SSHLibrary
Library    Collections
Library    String
Library    FakerLibrary    locale=fi_FI
Library    Dialogs

*** Variables ***
${HOST}             shell.metropolia.fi
${USER}             vilkosk
${PRIVATE_KEY}      C:\\Users\\Ville\\Downloads\\vilkosk-456.pem
${ADDRESS_FILE}     /home2-2/v/vilkosk/address.txt

*** Keywords ***
Remove Existing Address File
    [Arguments]    ${filename}
    [Documentation]    Removes the specified file from the remote server and logs the name from the first line
    Open Connection    ${HOST}    port=22
    Login With Public Key    ${USER}    ${PRIVATE_KEY}
    ${file_exists}    Run Keyword And Return Status    Execute Command    test -f ${filename}
    IF    ${file_exists}
        ${first_line}    Execute Command    head -n 1 ${filename}
        Log    Removing data for person: ${first_line}  # Fixed: Removed .stdout
        Execute Command    rm ${filename}
    END
    Close Connection

Create Address File With User Selection
    [Documentation]    Creates an address file with user-selected name and random address details on the remote server
    @{random_names}    Get Random Names    5
    ${selected_name}    Get Selection From User    Select a name    @{random_names}

    ${street}    Street Address
    ${postcode}    Postcode
    ${city}       City

    ${address_content}    Catenate    SEPARATOR=\n
    ...    ${selected_name}
    ...    ${street}
    ...    ${postcode} ${city}

    Open Connection    ${HOST}    port=22
    Login With Public Key    ${USER}    ${PRIVATE_KEY}
    Execute Command    echo "${address_content}" > ${ADDRESS_FILE}  # Fixed: Corrected remote file creation
    Close Connection

Verify Address File Line Count
    [Arguments]    ${expected_lines}=3
    [Documentation]    Verifies that the remote address file contains the expected number of lines
    Open Connection    ${HOST}    port=22
    Login With Public Key    ${USER}    ${PRIVATE_KEY}
    ${content}    Execute Command    cat ${ADDRESS_FILE}
    @{lines}    Split To Lines    ${content}  # Fixed: Removed .stdout
    Length Should Be    ${lines}    ${expected_lines}
    Close Connection

Get Random Names
    [Arguments]    ${count}
    [Documentation]    Generates a list of random names
    @{names}    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${name}    Name
        Append To List    ${names}    ${name}
    END
    RETURN    ${names}

*** Test Cases ***
Remove Address File Test
    [Documentation]    Tests removing an existing address file on the remote server
    Remove Existing Address File    ${ADDRESS_FILE}

Create New Address File Test
    [Documentation]    Tests creating a new address file with user selection on the remote server
    Create Address File With User Selection

Verify Address File Content Test
    [Documentation]    Tests that the remote address file contains exactly three lines
    Verify Address File Line Count    3
