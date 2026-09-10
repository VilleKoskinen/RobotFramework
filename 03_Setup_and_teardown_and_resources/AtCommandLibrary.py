import time
import serial

class AtCommandLibrary(object):
    ''' Library for interacting with a simple device using AT commands
    '''
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self, comp_port):
        # The target USB port briefly disappears after debugger flashing.
        deadline = time.monotonic() + 10
        while True:
            try:
                self._port = serial.Serial(comp_port, 115200, timeout=1)
                break
            except serial.SerialException:
                if time.monotonic() >= deadline:
                    raise
                time.sleep(0.2)

    def send_text(self, text):
        self._port.reset_input_buffer()
        self._port.write(bytes('AT+SEND="' + text + '"\n', 'iso-8859-1'))
    
    def send_command(self, command):
        self._port.reset_input_buffer()
        self._port.write(bytes(command + '\n', 'iso-8859-1'))
        
    def response_should_be(self, expected_text):
        text = self._port.readline().strip().decode('iso-8859-1')
        if text != expected_text:
            raise AssertionError('Expected: ' + expected_text + ' got: ' + text)
    def response_should_be_with_optional_echo(self, expected_text, command):
        """Allow one exact command echo; never discard arbitrary responses."""
        text = self._port.readline().strip().decode('iso-8859-1')
        if text == command:
            text = self._port.readline().strip().decode('iso-8859-1')
        if text != expected_text:
            raise AssertionError('Expected: ' + expected_text + ' got: ' + text)

    def close_port(self):
        self._port.close()
