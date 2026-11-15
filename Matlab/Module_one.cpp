#include <iostream>
#include <fstream>
#include <vector>
#include <string>

using namespace std;

const double OPEN_LEVEL = 50.0;
const double CLOSE_LEVEL = 40.0;
const double WAIT_TIME = 5.0;

int main()
{
    ifstream input("../Matlab/module_1_final_inputs.csv");

    if (!input)
    {
        cout << "Cannot open file." << endl;
        return 1;
    }

    vector<double> time;
    vector<double> height;

    string header;
    getline(input, header); 

    double t, h;
    char comma;

    while (input >> t >> comma >> h)
    {
        time.push_back(t);
        height.push_back(h);
    }

    input.close();

    vector<int> gateState;

    bool gateOpen = false;
    bool timerStarted = false;
    double startTime = 0;

    for (int i = 0; i < height.size(); i++)
    {
        double currentHeight = height[i];
        double currentTime = time[i];

        if (currentHeight >= OPEN_LEVEL)
        {
            gateOpen = true;
            timerStarted = false;
        }
        else if (gateOpen)
        {
            if (currentHeight < CLOSE_LEVEL)
            {
                if (!timerStarted)
                {
                    startTime = currentTime;
                    timerStarted = true;
                }

                if (currentTime - startTime >= WAIT_TIME)
                {
                    gateOpen = false;
                    timerStarted = false;
                }
            }
            else
            {
                timerStarted = false;
            }
        }

        if (gateOpen)
            gateState.push_back(1);
        else
            gateState.push_back(0);
    }

    ofstream output("../Matlab/actuator_states.csv");

    output << "time_min,actuator_state\n";

    for (int i = 0; i < gateState.size(); i++)
    {
        output << time[i] << "," << gateState[i] << endl;
    }

    output.close();

    cout << "Output file created successfully." << endl;

    return 0;
}