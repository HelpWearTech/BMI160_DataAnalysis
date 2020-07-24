%addpath('Gait\Gaitt\Quaternions');
%addpath('Gait\Gaitt\ximu_matlab_library');
clear;
Array=csvread('ecg.csv');
time = size(Array,1);
input_accX = Array(:, 8);
input_accY = Array(:, 9);
input_accZ = Array(:, 10);
input_gyrX = Array(:, 11);
input_gyrY = Array(:, 12);
input_gyrZ = Array(:, 13);
accX = zeros(time/12,1);
accY = zeros(time/12,1);
accZ = zeros(time/12,1);
gyrX = zeros(time/12,1);
gyrY = zeros(time/12,1);
gyrZ = zeros(time/12,1);
counter = 1;
for n = 1 : length(input_accX)
  if mod(n-1,12) == 0 || n == 1
    % Convert raw data into m/s^2
    accX(counter,1) = ((input_accX(n,1)-32768)/16384)*9.81;
    accY(counter,1) = ((input_accY(n,1)-32768)/16384)*9.81;
    accZ(counter,1) = ((input_accZ(n,1)-32768)/16384)*9.81;
    % Convert raw data into rad/s
    gyrX(counter,1) = ((input_gyrX(n,1)-32768)/16.4)*pi/180;
    gyrY(counter,1) = ((input_gyrY(n,1)-32768)/16.4)*pi/180;
    gyrZ(counter,1) = ((input_gyrZ(n,1)-32768)/16.4)*pi/180;
    counter = counter + 1;
  end
end


decim = 1;
Fs = 25;
fuse = imufilter('SampleRate',25,'DecimationFactor',decim,'ReferenceFrame','NED','AccelerometerNoise',0.000036,'GyroscopeNoise', 0.0014*3.14/180);
accelerometerReadings = [accX accY accZ];
gyroscopeReadings = [gyrX gyrY gyrZ];
q = fuse(accelerometerReadings,gyroscopeReadings);
time = (0:decim:size(accelerometerReadings,1)-1)/Fs;
eulerAngles = eulerd(q,'XYZ','frame');
figure(1);
plot(time,eulerAngles);
title('Orientation Estimate')
legend('X-axis', 'Y-axis', 'Z-axis')
xlabel('Time (s)')
ylabel('Rotation (degrees)')

zeroed_eulerAngles = eulerAngles;
for n = size(eulerAngles):-1:1
  if n > 1
    zeroed_eulerAngles(n,1) = (eulerAngles(n,1) + 180) - (eulerAngles(1,1) + 180);
    zeroed_eulerAngles(n,2) = (eulerAngles(n,2) + 180) - (eulerAngles(1,2) + 180);
    zeroed_eulerAngles(n,3) = (eulerAngles(n,3) + 180) - (eulerAngles(1,3) + 180);
  end
  if n == 1
    zeroed_eulerAngles(1,1) =  0;
    zeroed_eulerAngles(1,2) = 0;
    zeroed_eulerAngles(1,3) = 0;
  end
end
figure(2);
plot(time,zeroed_eulerAngles);
title('Zeroed Orientation Estimate')
legend('X-axis', 'Y-axis', 'Z-axis')
xlabel('Time (s)')
ylabel('Rotation (degrees)')

abs_eulerAngles = eulerAngles;
for n = size(eulerAngles):-1:1
  if n >= 1
    abs_eulerAngles(n,1) = abs(eulerAngles(n,1));
    abs_eulerAngles(n,2) = abs(eulerAngles(n,2));
    abs_eulerAngles(n,3) = abs(eulerAngles(n,3));
  end
  if n == 1

  end
end
figure(3);
plot(time,abs_eulerAngles);
title('Absolute Orientation Estimate')
legend('X-axis', 'Y-axis', 'Z-axis')
xlabel('Time (s)')
ylabel('Rotation (degrees)')
