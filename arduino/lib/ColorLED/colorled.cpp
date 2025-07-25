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

#include "colorled.h"

ColorLED::ColorLED(uint8_t redPin, uint8_t greenPin, uint8_t bluePin)
{
    _state = IDLE;

    _redPin = redPin;
    _greenPin = greenPin;
    _bluePin = bluePin;
}

void ColorLED::begin()
{
    pinMode(_redPin, OUTPUT);
    pinMode(_greenPin, OUTPUT);
    pinMode(_bluePin, OUTPUT);
}

void ColorLED::applyColor(Color color)
{
    switch (color) {
        case Color::RED:
          applyRGB(255, 0, 0);
          break;
        case Color::GREEN:
          applyRGB(0, 255, 0);
          break;
        case Color::BLUE:
          applyRGB(0, 0, 255);
          break;
        case Color::YELLOW:
          applyRGB(255, 255, 0);
          break;
        case Color::CYAN:
          applyRGB(0, 255, 255);
          break;
        case Color::MAGENTA:
          applyRGB(255, 0, 255);
          break;
        case Color::WHITE:
          applyRGB(255, 255, 255);
          break;
    }
}

void ColorLED::applyRGB(uint8_t red, uint8_t green, uint8_t blue)
{
    analogWrite(_redPin, red);
    analogWrite(_greenPin, green);
    analogWrite(_bluePin, blue);
}

void ColorLED::on(Color color)
{
    applyColor(color);
    _state = IDLE;
}

void ColorLED::off()
{
    applyRGB(0, 0, 0);
    _state = IDLE;
}

void ColorLED::blink(Color color, int onDuration, int offDuration, int repeatCount)
{
    _onDuration = onDuration;
    _offDuration = offDuration;
    _repeatCount = repeatCount;

    _currentRepeat = 0;
    _lastChange = millis();

    _currentColor = color;
    applyColor(color);

    _state = ON;
}

void ColorLED::update()
{
    switch (_state) {
        case ON:
            if (millis() - _lastChange < (unsigned long)_onDuration)
              break;

            off();
            _lastChange = millis();
            _state = OFF;
            break;

        case OFF:
            if (millis() - _lastChange < (unsigned long)_offDuration)
              break;

            if (_repeatCount == -1 || ++_currentRepeat < _repeatCount) {
                applyColor(_currentColor);
                _lastChange = millis();
                _state = ON;
            } else
                _state = IDLE;
            break;
    }
}

