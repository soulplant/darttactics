library tactics_util;

import 'dart:math';

const int FPS = 60;

int msToTicks(int ms) => secondsToTicks(ms / 1000.0);
int secondsToTicks(double secs) {
  return (secs * FPS).floor();
}

double clampDouble(double x, double mag) {
  if (x < -mag) {
    x = -mag;
  }
  if (x > mag) {
    x = mag;
  }
  return x;
}

int clampInt(int x, int mag) {
  if (x < -mag) {
    x = -mag;
  }
  if (x > mag) {
    x = mag;
  }
  return x;
}

int signum(int x) {
  if (x < 0) {
    return -1;
  }
  if (x > 0) {
    return 1;
  }
  return 0;
}

abs(x) => x < 0 ? -x : x;

Point scalePoint(Point p, int factor) => new Point(p.x * factor, p.y * factor);