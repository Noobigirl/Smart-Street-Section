clear;
clc;

% randomize inputs for rainfall and linear inputs for time (Assuming our min I is 2mm = light rain, and max I is 80mm= violent storm)
% step 1 :)

minI=2;
maxI=80;

% Here, we are trying to see the behavior for varying rainfall

% column array containing the time (in hr) and rainfall intensity (in
% mm/hr)
test_cases = [linspace(1, 24, 200);linspace(minI,maxI,200);];

time = test_cases(1, :);
I = test_cases(2,:);
rainfall = movmean(I, 30); %what does this line do?

% Tests should also be run to find the ideal runoff coefficient C
CP = 0.85; % for pavement
CBr = 0.15; % for Bio-retention surface

%             pavement area; bio-retention surface area
Area_tests = [600, 500, 800; 400, 500, 200;];

Qin_1 = zeros (1, 200);
Vin_1 = zeros (1, 200);

Qin_2 = zeros (1, 200);
Vin_2 = zeros (1, 200);

Qin_3 = zeros (1, 200);
Vin_3 = zeros (1, 200);


for i = 1:200

    Cc = ((Area_tests(1, 1)*CP)+(Area_tests(2, 1)*CBr))/1000;
    Vin_1(i)= Cc*rainfall(i)*(Area_tests(1, 1)+Area_tests(2, 1));
    Qin_1(i)=(Cc*rainfall(i)*(Area_tests(1, 1)+Area_tests(2, 1)))/(3.6*10^6);
end

for i = 1:200

    Cc = ((Area_tests(1, 2)*CP)+(Area_tests(2, 2)*CBr))/1000;
    Vin_2(i)= Cc*rainfall(i)*(Area_tests(1, 2)+Area_tests(2, 2));
    Qin_2(i)=(Cc*rainfall(i)*(Area_tests(1, 2)+Area_tests(2, 2)))/(3.6*10^6);
end
for i = 1:200

    Cc = ((Area_tests(1, 3)*CP)+(Area_tests(2, 3)*CBr))/1000;
    Vin_3(i)= Cc*rainfall(i)*(Area_tests(1, 3)+Area_tests(2, 3));
    Qin_3(i)= (Cc*rainfall(i)*(Area_tests(1, 3)+Area_tests(2, 3)))/(3.6*10^6);
end

figure(1);
plot(time, rainfall, 'LineWidth',0.5, 'Color',"r");
xlabel('Time (seconds)');
ylabel('Rainfall (mm)');
title('Graph of rainfall against time');
grid on;


figure(2);
plot(time, Qin_1, 'LineWidth', 0.5, 'Color',"r");
hold on;
plot(time, Qin_2, 'LineWidth', 0.5,'Color',"b");
plot(time, Qin_3, 'LineWidth', 0.5, 'Color',"g");
hold off;
xlabel('Time (minutes)');
ylabel('Inflow rate with varying Area');
legend('600 x 400', '500 x 500', '800 x 200', 'Location', 'best');
grid on;


%step 2 :)
% calculating the amount of water that infiltrates, what remains and the
% height of whatever remains

h1 = zeros (1, 200);
h2 = zeros (1, 200);
h3 = zeros (1, 200);

delta_t = (time(2) - time(1));
infiltration_rate = 80;

puddle_1 = zeros(1, 200);
for i = 2:200
    water_absorbed = (Area_tests(2, 1)*infiltration_rate)/(3.6*10^6);
    puddle_1(i) = Qin_1(i)-water_absorbed;

    if puddle_1(i)<=0
        h1(i)=0;
    else
        h1(i) = (h1(i-1)+(puddle_1(i) * delta_t) / Area_tests(2, 1));
    end
end

puddle_2 = zeros (1, 200);
for i = 2:200
    water_absorbed = ((Area_tests(2, 2)*infiltration_rate)/(3.6*10^6));
    puddle_2(i) = Qin_2(i)-water_absorbed;

    if puddle_2(i)<=0 
        h2(i)=0;
    else
        h2(i) = (h2(i-1)+(puddle_2(i) * delta_t) / Area_tests(2, 2));
    end
end

puddle_3 = zeros (1, 200);
for i = 2:200
    water_absorbed = (Area_tests(2, 3)*infiltration_rate)/(3.6*10^6);
    puddle_3(i)= Qin_3(i)-water_absorbed;

    if puddle_3(i)<=0
        h3(i)=0;
    else
        h3(i) = (h3(i-1)+(puddle_3(i) * delta_t) / Area_tests(2, 3));
    end
end

figure(3);
plot(time,h1, 'LineWidth', 0.5, 'Color','r');
hold on;
plot(time, h2, 'LineWidth', 0.5, 'Color', 'b');
plot(time, h3,'LineWidth', 0.5, 'Color','g');
hold off;
xlabel ('time(seconds)');
ylabel ('height of puddle(mm)');
legend('600 x 400', '500 x 500', '800 x 200', 'Location', 'best');
grid on;


% creating a CSV file with 3 values: Q, h and t 

time_column = time(:);
Q_column = Qin_1(:);
h_column = h1(:);

module_1_inputs = table (time_column, Q_column, h_column);
writetable(module_1_inputs, 'module_1_inputs.csv');


