/*
  ColorLED - A simple RGB LED control library.
  Copyright (c) 2025 gadefoxren@gmail.com

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#pragma once

#include <Arduino.h>

class ColorLED
{
public:
    enum Color { RED, GREEN, BLUE, MAGENTA, CYAN, YELLOW, WHITE };

    ColorLED(uint8_t redPin, uint8_t greenPin, uint8_t bluePin);

    void begin();

    void on(Color color);
    void off();
    void blink(Color color, int onDuration, int offDuration, int repeatCount);

    inline void error() { blink(Color::RED, 250, 250, -1); }  // blink red, 250ms on, 250ms off, repeat forever

    void update();  // Call regularly from loop()

private:
    uint8_t _redPin, _greenPin, _bluePin;

    enum State { IDLE, ON, OFF };
    State _state;

    unsigned long _lastChange;
    int _onDuration;
    int _offDuration;
    int _repeatCount;
    int _currentRepeat;
    Color _currentColor;

    void applyColor(Color color);
    void applyRGB(uint8_t red, uint8_t green, uint8_t blue);
};
