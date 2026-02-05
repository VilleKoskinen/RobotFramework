*** Settings ***
Documentation       Car dealer website test
Library             SeleniumLibrary
Library             String
Library             Process

Test Setup          Start Container
Test Teardown       Stop Container

*** Variables ***
${LOGIN URL}                http://localhost:3000
${BROWSER}                  Chrome
${SCREENSHOT_AFTER_ADDS}    Screenshot_after_adds.png
${SCREENSHOT_AFTER_DELETE}  Screenshot_after_delete.png

@{CAR_MAKES}    Ford    Chevrolet    Toyota    Honda    Nissan    BMW    Mercedes    Volkswagen    Hyundai    Kia    Audi
@{CAR_MODELS}   Focus   Malibu       Camry     Accord   Altima    3-Series  C-Class    Golf        Elantra   Optima  A4

*** Test Cases ***
Add and Remove Cars
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window

    # Add three random cars
    Add Random Cars    3

    # Add a random car with plate ABC-123
    Add Random Car With Plate    ABC-123

    # Add two more random cars
    Add Random Cars    2

    # Take screenshot after cars have been added
    Take Screenshot    ${SCREENSHOT_AFTER_ADDS}

    # Remove the car with plate ABC-123
    Remove Car By Plate    ABC-123

    # Take screenshot after removing the car
    Take Screenshot    ${SCREENSHOT_AFTER_DELETE}

    # Verify that the car with plate ABC-123 does not exist on the main page
    Verify Car Not Present    ABC-123

    Close Browser

*** Keywords ***
Add Random Cars
    [Arguments]    ${count}
    FOR    ${index}    IN RANGE    ${count}
        ${make}=    Get Random Car Make
        ${model}=   Get Random Car Model
        ${mileage}=    Generate Random Number    1000    100000
        ${year}=      Generate Random Number    2000    2022
        ${plate}=     Generate Random Plate    6
        Add Car    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    END

Add Random Car With Plate
    [Arguments]    ${plate}
    ${make}=    Get Random Car Make
    ${model}=   Get Random Car Model
    ${mileage}=    Generate Random Number    1000    100000
    ${year}=      Generate Random Number    2000    2022
    Add Car    ${make}    ${model}    ${mileage}    ${year}    ${plate}

Add Car
    [Arguments]    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    Wait Until Element Is Visible    link=Add a car    timeout=10s
    Click Link    Add a car
    Wait Until Element Is Visible    id=make-input    timeout=10s
    Input Text       id=make-input       ${make}
    Input Text       id=model-input      ${model}
    Input Text       id=mileage-input    ${mileage}
    Input Text       id=year-input       ${year}
    Input Text       id=plate-input      ${plate}
    Click Button     xpath=//input[@type='submit' and @value='Add a new car']
    Wait Until Page Contains    ${plate}    timeout=10s

Get Random Car Make
    ${make}=    Evaluate    random.choice(${CAR_MAKES})    modules=random
    RETURN    ${make}

Get Random Car Model
    ${model}=    Evaluate    random.choice(${CAR_MODELS})    modules=random
    RETURN    ${model}

Generate Random Plate
    [Arguments]    ${length}
    ${plate}=    Evaluate    ''.join(random.choices(string.ascii_uppercase + string.digits, k=${length}))    modules=random,string
    RETURN    ${plate}

Generate Random Number
    [Arguments]    ${min}    ${max}
    ${number}=    Evaluate    random.randint(${min}, ${max})    modules=random
    RETURN    ${number}

Remove Car By Plate
    [Arguments]    ${plate}
    Wait Until Element Is Visible    xpath=//a[div//div[@class='car-specs car-plate']//span[@class='field-value' and text()='${plate}']]    timeout=10s
    Simulate Right Click    xpath=//a[div//div[@class='car-specs car-plate']//span[@class='field-value' and text()='${plate}']]
    Handle Deletion Confirmation
    Wait Until Page Does Not Contain    ${plate}    timeout=10s

Simulate Right Click
    [Arguments]    ${locator}
    Open Context Menu    ${locator}
    Sleep    1s

Handle Deletion Confirmation
    
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5x    1s    Alert Should Be Present
    ${status}    ${result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT    timeout=5s
   

Verify Car Not Present
    [Arguments]    ${plate}
    Go To    ${LOGIN URL}
    Wait Until Page Does Not Contain    ${plate}    timeout=10s

Take Screenshot
    [Arguments]    ${filename}
    Capture Page Screenshot    ${filename}

Start Container
    Log     Starting container
    Run Process     docker-compose    up    --detach

Stop Container
    Log     Stopping container
    Close Browser
    Run Process     docker-compose    down
