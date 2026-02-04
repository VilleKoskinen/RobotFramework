*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    Dialogs
Library    FakerLibrary    locale=fi_FI
Library    SSHLibrary

*** Variables ***
${SSH_HOST}         shell.metropolia.fi
${SSH_USER}         aleksame
${SSH_KEY_PATH}     /Users/amerilain/.ssh/aleksame-459.pem
${ADDRESS_FILE}     address.txt
${REMOTE_PATH}      /home2-3/a/aleksame/

*** Keywords ***
Establish SSH Connection
    Open Connection    ${SSH_HOST}
    Login With Public Key    ${SSH_USER}    ${SSH_KEY_PATH}

Close SSH Connection
    Close Connection

Get Remote Random Names
    [Arguments]    ${number_of_names}
    ${names}    Create List
    FOR    ${i}    IN RANGE    ${number_of_names}
        ${name}    FakerLibrary.Name
        Append To List    ${names}    ${name}
    END
    RETURN    ${names}

Remove Existing Remote Address File
    [Arguments]    ${file_name}
    ${remote_file}    Set Variable    ${REMOTE_PATH}${file_name}
    Establish SSH Connection
    ${file_exists}    Run Keyword And Return Status    Execute Command    test -f ${remote_file}
    IF    ${file_exists}
        ${file_content}    Execute Command    cat ${remote_file}
        ${lines}    Split String    ${file_content}    \n
        ${first_line}    Set Variable    ${lines[0]}
        Log    Removing file for person: ${first_line}
        Execute Command    rm ${remote_file}
    ELSE
        Log    File does not exist
    END
    Close SSH Connection

Create New Remote Address File
    ${names}    Get Remote Random Names    5
    ${name}    Get Selection From User    Select a name    @{names}
    ${street_address}    FakerLibrary.Street Address
    ${postcode_city}    FakerLibrary.City
    Write Remote Address To File    ${name}    ${street_address}    ${postcode_city}

Write Remote Address To File
    [Arguments]    ${name}    ${street_address}    ${postcode_city}
    ${remote_file}    Set Variable    ${REMOTE_PATH}${ADDRESS_FILE}
    Establish SSH Connection
    ${write_name}    Execute Command    echo "${name}" > ${remote_file}
    ${write_address}    Execute Command    echo "${street_address}" >> ${remote_file}
    ${write_postcode}    Execute Command    echo "${postcode_city}" >> ${remote_file}
    ${file_exists}    Run Keyword And Return Status    Execute Command    test -f ${remote_file}
    Close SSH Connection

Check Remote Address File Content
    ${remote_file}    Set Variable    ${REMOTE_PATH}${ADDRESS_FILE}
    Establish SSH Connection
    ${content}    Execute Command    cat ${remote_file}
    Should Contain    ${content}    \n
    ${lines}    Get Length    ${content.splitlines()}
    Should Be Equal As Numbers    ${lines}    3
    Log    File content is valid
    Close SSH Connection

*** Test Cases ***
Remove Existing Remote Address File Test
    Remove Existing Remote Address File    ${ADDRESS_FILE}

Create New Remote Address File Test
    Create New Remote Address File

Check Remote Address File Content Test
    Check Remote Address File Content